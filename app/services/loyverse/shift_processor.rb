module Loyverse
  # Servicio para procesar shifts de Loyverse y crear TurnClosures
  # Implementa la estrategia híbrida: Shift + Receipts
  #
  # Flujo:
  # 1. Recibe shift_id del webhook shifts.create
  # 2. Hace GET /shifts/{id} para obtener datos del shift
  # 3. Hace GET /receipts filtrando por rango de tiempo del shift
  # 4. Asocia receipts con el shift
  # 5. Calcula totales exactos por payment_type desde receipts
  # 6. Crea TurnClosure con datos precisos
  class ShiftProcessor
    attr_reader :shift_id, :client, :loyverse_shift

    def initialize(shift_id)
      @shift_id = shift_id
      @client = Loyverse::Client.new
      @loyverse_shift = nil
    end

    # Procesa el shift completo
    def process
      Rails.logger.info("🔄 Procesando shift #{shift_id}")

      ActiveRecord::Base.transaction do
        # 1. Fetch y crear shift
        fetch_and_create_shift

        # 2. Fetch y asociar receipts del turno
        fetch_and_associate_receipts

        # 3. Crear TurnClosure con totales exactos
        create_turn_closure

        Rails.logger.info("✅ Shift #{shift_id} procesado exitosamente")

        {
          success: true,
          shift: @loyverse_shift,
          receipts_count: @loyverse_shift.loyverse_receipts.count,
          turn_closure: @loyverse_shift.turn_closure
        }
      end
    rescue => e
      Rails.logger.error("❌ Error procesando shift #{shift_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      {
        success: false,
        error: e.message
      }
    end

    private

    # Paso 1: Obtener datos del shift de Loyverse API y crear registro
    def fetch_and_create_shift
      Rails.logger.info("  📥 Obteniendo datos del shift...")

      shift_data = client.get_shift(shift_id)

      @loyverse_shift = LoyverseShift.find_or_initialize_by(loyverse_id: shift_id)

      @loyverse_shift.assign_attributes(
        store_id: shift_data["store_id"],
        pos_device_id: shift_data["pos_device_id"],
        opened_at: shift_data["opened_at"],
        closed_at: shift_data["closed_at"],
        opened_by_employee: shift_data["opened_by_employee"],
        closed_by_employee: shift_data["closed_by_employee"],

        # Cash management
        starting_cash: shift_data["starting_cash"],
        cash_payments: shift_data["cash_payments"],
        cash_refunds: shift_data["cash_refunds"],
        paid_in: shift_data["paid_in"],
        paid_out: shift_data["paid_out"],
        expected_cash: shift_data["expected_cash"],
        actual_cash: shift_data["actual_cash"],

        # Sales totals
        gross_sales: shift_data["gross_sales"],
        refunds: shift_data["refunds"],
        discounts: shift_data["discounts"],

        # Extras
        tip: shift_data["tip"] || 0,
        surcharge: shift_data["surcharge"] || 0,

        # Full JSON
        shift_data: shift_data
      )

      @loyverse_shift.save!

      Rails.logger.info("  ✅ Shift creado/actualizado")
    end

    # Paso 2: Obtener todos los receipts del turno y asociarlos
    def fetch_and_associate_receipts
      Rails.logger.info("  📥 Obteniendo receipts del turno...")

      # Filtrar receipts por rango de tiempo del shift
      # La API de Loyverse usa created_at_min y created_at_max
      receipts_data = client.get_receipts(
        created_at_min: @loyverse_shift.opened_at.iso8601,
        created_at_max: @loyverse_shift.closed_at.iso8601,
        store_id: @loyverse_shift.store_id
      )

      receipts_list = receipts_data["receipts"] || []

      Rails.logger.info("  📊 Encontrados #{receipts_list.count} receipts")

      # Crear o actualizar cada receipt y asociarlo con el shift
      receipts_list.each do |receipt_data|
        loyverse_receipt = LoyverseReceipt.find_or_initialize_by(
          loyverse_id: receipt_data["receipt_id"]
        )

        loyverse_receipt.assign_attributes(
          receipt_number: receipt_data["receipt_number"],
          receipt_type: receipt_data["receipt_type"],
          total_money: receipt_data["total_money"],
          total_tax: receipt_data["total_tax"],
          receipt_data: receipt_data,
          loyverse_created_at: receipt_data["created_at"],
          synced_at: Time.current,
          loyverse_shift: @loyverse_shift
        )

        loyverse_receipt.save!
      end

      Rails.logger.info("  ✅ #{receipts_list.count} receipts asociados al shift")
    end

    # Paso 3: Crear TurnClosure con totales exactos calculados desde receipts
    def create_turn_closure
      # No crear si ya existe TurnClosure
      if @loyverse_shift.converted?
        Rails.logger.info("  ⚠️  Ya existe TurnClosure para este shift")
        return @loyverse_shift.turn_closure
      end

      Rails.logger.info("  💰 Creando TurnClosure...")

      # Calcular totales exactos desde receipts (estrategia híbrida)
      payment_totals = @loyverse_shift.calculate_payment_totals

      Rails.logger.info("  📊 Totales calculados:")
      Rails.logger.info("     - Efectivo: $#{payment_totals[:cash]}")
      Rails.logger.info("     - Tarjeta: $#{payment_totals[:card]}")
      Rails.logger.info("     - Transferencia: $#{payment_totals[:custom]}")
      Rails.logger.info("     - Total: $#{payment_totals[:total]}")

      turn_closure = TurnClosure.create!(
        closure_date: @loyverse_shift.closed_at.to_date,
        closure_number: generate_closure_number,

        # Totales por tipo de pago (desde receipts)
        cash_collected: payment_totals[:cash],
        card_income_gross: payment_totals[:card],
        transfer_income_gross: payment_totals[:custom],

        # Total general
        total_income: @loyverse_shift.gross_sales,

        # Notas con info del shift
        notes: generate_notes
      )

      # Asociar shift con TurnClosure
      @loyverse_shift.update!(turn_closure: turn_closure)

      # Actualizar saldos de cuentas (efectivo a Bóveda, tarjetas/transferencias a Mercado Pago)
      update_account_balances(payment_totals)

      Rails.logger.info("  ✅ TurnClosure ##{turn_closure.closure_number} creado")

      turn_closure
    end

    # Genera número único de cierre
    def generate_closure_number
      date_prefix = @loyverse_shift.closed_at.strftime("%Y%m%d")
      sequence = TurnClosure.where("closure_number LIKE ?", "#{date_prefix}%").count + 1
      "#{date_prefix}-#{sequence.to_s.rjust(3, '0')}"
    end

    # Genera notas descriptivas del turno
    def generate_notes
      lines = []
      lines << "Turno cerrado automáticamente desde Loyverse"
      lines << "Shift ID: #{@loyverse_shift.loyverse_id}"
      lines << "Horario: #{@loyverse_shift.opened_at.strftime('%H:%M')} - #{@loyverse_shift.closed_at.strftime('%H:%M')}"
      lines << "Duración: #{@loyverse_shift.duration_hours} horas"

      # Agregar info de cuadre de efectivo
      if @loyverse_shift.cash_balanced?
        lines << "✅ Cuadre de efectivo: Correcto"
      else
        diff = @loyverse_shift.cash_difference
        status = diff.positive? ? "Sobrante" : "Faltante"
        lines << "⚠️ Cuadre de efectivo: #{status} de $#{diff.abs}"
      end

      lines << "Receipts procesados: #{@loyverse_shift.loyverse_receipts.count}"

      lines.join("\n")
    end

    # Actualiza saldos de cuentas según totales
    def update_account_balances(totals)
      # Efectivo → Bóveda (cuenta tipo vault)
      vault_account = Account.find_by(account_type: "vault")
      if vault_account && totals[:cash] > 0
        vault_account.increment!(:balance, totals[:cash])
        Rails.logger.info("  💰 Bóveda actualizada: +$#{totals[:cash]}")
      end

      # Tarjetas + Transferencias → Mercado Pago (cuenta tipo bank)
      bank_account = Account.find_by(account_type: "bank", name: "Mercado Pago")
      digital_income = totals[:card] + totals[:custom]

      if bank_account && digital_income > 0
        bank_account.increment!(:balance, digital_income)
        Rails.logger.info("  💳 Mercado Pago actualizado: +$#{digital_income}")
      end
    end
  end
end
