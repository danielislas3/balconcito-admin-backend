module Loyverse
  class SyncService
    attr_reader :client, :start_date, :end_date

    def initialize(start_date: nil, end_date: nil, api_token: nil)
      @client = Loyverse::Client.new(api_token)
      @start_date = start_date&.to_date || Date.today
      @end_date = end_date&.to_date || Date.today
    end

    # Sincronizar receipts en un rango de fechas
    def sync_receipts
      Rails.logger.info("🔄 Iniciando sincronización de Loyverse receipts: #{start_date} a #{end_date}")

      receipts_synced = 0
      receipts_created = 0
      errors = []

      all_receipts = fetch_all_receipts

      all_receipts.each do |receipt_data|
        begin
          loyverse_receipt = create_or_update_receipt(receipt_data)
          receipts_synced += 1

          # Crear TurnClosure si no existe
          unless loyverse_receipt.converted?
            turn_closure = Loyverse::ReceiptMapper.new(loyverse_receipt).create_turn_closure
            receipts_created += 1
            Rails.logger.info("✅ TurnClosure creado: #{turn_closure.closure_number}")
          end
        rescue => e
          errors << { receipt: receipt_data['receipt_number'], error: e.message }
          Rails.logger.error("❌ Error procesando receipt #{receipt_data['receipt_number']}: #{e.message}")
        end
      end

      # Actualizar última sincronización
      LoyverseConfig.instance.update_last_sync!

      {
        success: true,
        receipts_synced: receipts_synced,
        turn_closures_created: receipts_created,
        errors: errors,
        period: "#{start_date} a #{end_date}"
      }
    end

    # Sincronizar payment types y crear mappings
    def sync_payment_types
      Rails.logger.info("🔄 Sincronizando payment types de Loyverse...")

      response = client.get_payment_types
      payment_types = response['payment_types'] || []

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

    def fetch_all_receipts
      all_receipts = []
      cursor = nil

      loop do
        params = build_params(cursor)
        response = client.get_receipts(params)

        receipts = response['receipts'] || []
        all_receipts.concat(receipts)

        cursor = response['cursor']
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
      LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_data['id']) do |receipt|
        receipt.receipt_number = receipt_data['receipt_number']
        receipt.receipt_type = receipt_data['receipt_type']
        receipt.total_money = receipt_data['total_money']
        receipt.total_tax = receipt_data['total_tax']
        receipt.receipt_data = receipt_data
        receipt.loyverse_created_at = receipt_data['created_at']
        receipt.synced_at = Time.current
      end
    end
  end
end
