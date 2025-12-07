module Loyverse
  class SyncService
    attr_reader :client, :start_date, :end_date

    def initialize(start_date: nil, end_date: nil, api_token: nil)
      @client = Loyverse::Client.new(api_token)
      @start_date = start_date&.to_date || Date.today
      @end_date = end_date&.to_date || Date.today
    end

    # Sincronizar shifts (turnos de caja) en un rango de fechas
    # RECOMENDADO: Usa esto para crear TurnClosures correctamente
    def sync_shifts
      Rails.logger.info("🔄 Iniciando sincronización de Loyverse shifts: #{start_date} a #{end_date}")

      shifts_synced = 0
      turn_closures_created = 0
      errors = []

      all_shifts = fetch_all_shifts

      all_shifts.each do |shift_data|
        begin
          shift_id = shift_data["id"]

          # Usar ShiftProcessor para procesar cada shift
          result = Loyverse::ShiftProcessor.new(shift_id).process

          if result[:success]
            shifts_synced += 1
            turn_closures_created += 1 if result[:turn_closure]
            Rails.logger.info("✅ Shift procesado: #{shift_id}")
          else
            errors << { shift: shift_id, error: result[:error] }
          end
        rescue => e
          errors << { shift: shift_data["id"], error: e.message }
          Rails.logger.error("❌ Error procesando shift #{shift_data['id']}: #{e.message}")
        end
      end

      # Actualizar última sincronización
      LoyverseConfig.instance.update_last_sync!

      {
        success: true,
        shifts_synced: shifts_synced,
        turn_closures_created: turn_closures_created,
        errors: errors,
        period: "#{start_date} a #{end_date}"
      }
    end

    # Sincronizar receipts en un rango de fechas
    # NOTA: Solo guarda receipts, NO crea TurnClosures
    # Para crear TurnClosures usa sync_shifts en su lugar
    def sync_receipts(create_turn_closures: false)
      Rails.logger.info("🔄 Iniciando sincronización de Loyverse receipts: #{start_date} a #{end_date}")

      receipts_synced = 0
      turn_closures_created = 0
      errors = []

      all_receipts = fetch_all_receipts

      all_receipts.each do |receipt_data|
        begin
          loyverse_receipt = create_or_update_receipt(receipt_data)
          receipts_synced += 1

          # Solo crear TurnClosure si se solicita explícitamente
          # NO RECOMENDADO: Usa sync_shifts en su lugar
          if create_turn_closures && !loyverse_receipt.converted?
            turn_closure = Loyverse::ReceiptMapper.new(loyverse_receipt).create_turn_closure
            turn_closures_created += 1
            Rails.logger.info("✅ TurnClosure creado: #{turn_closure.closure_number}")
          end
        rescue => e
          errors << { receipt: receipt_data["receipt_number"], error: e.message }
          Rails.logger.error("❌ Error procesando receipt #{receipt_data['receipt_number']}: #{e.message}")
        end
      end

      # Actualizar última sincronización
      LoyverseConfig.instance.update_last_sync!

      {
        success: true,
        receipts_synced: receipts_synced,
        turn_closures_created: turn_closures_created,
        errors: errors,
        period: "#{start_date} a #{end_date}"
      }
    end

    # Sincronizar payment types y crear mappings
    def sync_payment_types
      Rails.logger.info("🔄 Sincronizando payment types de Loyverse...")

      response = client.get_payment_types
      payment_types = response["payment_types"] || []

      payment_types.each do |pt|
        mapping = LoyversePaymentMapping.create_from_loyverse_data(pt)
        mapping.auto_map! unless mapping.mapped?

        Rails.logger.info("✅ Payment type mapeado: #{pt['name']} (#{pt['type']})")
      end

      {
        success: true,
        payment_types_count: payment_types.count
      }
    end

    private

    def fetch_all_shifts
      all_shifts = []
      cursor = nil

      Rails.logger.info("📥 Fetching shifts from Loyverse API...")

      loop do
        params = build_shifts_params(cursor)
        response = client.get_shifts(params)

        shifts = response["shifts"] || []
        all_shifts.concat(shifts)

        cursor = response["cursor"]
        break if cursor.blank? || shifts.empty?

        # Rate limiting: esperar 1 segundo cada 50 requests
        sleep(1) if all_shifts.count % 50 == 0
      end

      Rails.logger.info("📥 Fetched #{all_shifts.count} shifts from Loyverse")
      all_shifts
    rescue => e
      Rails.logger.error("❌ Error fetching shifts: #{e.message}")
      Rails.logger.warn("⚠️  Si la API de Loyverse no soporta GET /shifts con filtros,")
      Rails.logger.warn("    usa webhooks para recibir shifts en tiempo real")
      []
    end

    def build_shifts_params(cursor = nil)
      params = {
        closed_at_min: start_date.beginning_of_day.iso8601,
        closed_at_max: end_date.end_of_day.iso8601,
        limit: 100 # Ajustar según límite de Loyverse
      }

      params[:cursor] = cursor if cursor.present?
      params
    end

    def fetch_all_receipts
      all_receipts = []
      cursor = nil

      loop do
        params = build_params(cursor)
        response = client.get_receipts(params)

        receipts = response["receipts"] || []
        all_receipts.concat(receipts)

        cursor = response["cursor"]
        break if cursor.blank? || receipts.empty?

        # Rate limiting: esperar 1 segundo cada 50 requests
        sleep(1) if all_receipts.count % 50 == 0
      end

      Rails.logger.info("📥 Fetched #{all_receipts.count} receipts from Loyverse")
      all_receipts
    end

    def build_params(cursor = nil)
      params = {
        created_at_min: start_date.beginning_of_day.iso8601,
        created_at_max: end_date.end_of_day.iso8601,
        limit: 250 # Max permitido por Loyverse
      }

      params[:cursor] = cursor if cursor.present?
      params
    end

    def create_or_update_receipt(receipt_data)
      # Loyverse usa receipt_number como identificador único
      receipt_number = receipt_data["receipt_number"]

      if receipt_number.blank?
        raise "Receipt sin receipt_number: #{receipt_data.inspect}"
      end

      # Usar receipt_number como loyverse_id ya que Loyverse no devuelve 'id' en GET /receipts
      LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_number) do |receipt|
        receipt.receipt_number = receipt_number
        receipt.receipt_type = receipt_data["receipt_type"]
        receipt.total_money = receipt_data["total_money"]
        receipt.total_tax = receipt_data["total_tax"]
        receipt.receipt_data = receipt_data
        receipt.loyverse_created_at = receipt_data["created_at"]
        receipt.synced_at = Time.current
      end
    end
  end
end
