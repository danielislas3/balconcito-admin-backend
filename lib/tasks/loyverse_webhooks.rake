namespace :loyverse do
  namespace :webhooks do
    desc "Testear procesamiento de webhooks localmente"
    task :test_processing, [:receipt_id] => :environment do |t, args|
      receipt_id = args[:receipt_id]

      unless receipt_id
        puts "❌ Error: Debes proporcionar un receipt_id"
        puts "   Uso: rails loyverse:webhooks:test_processing[receipt_id]"
        exit 1
      end

      puts "🧪 Testeando procesamiento de webhook para receipt #{receipt_id}..."

      # Simular webhook event
      event = LoyverseWebhookEvent.create!(
        event_id: "test_#{Time.now.to_i}",
        event_type: LoyverseWebhookEvent::RECEIPT_CREATED,
        payload: {
          event_id: "test_#{Time.now.to_i}",
          event_type: LoyverseWebhookEvent::RECEIPT_CREATED,
          resource_type: 'receipt',
          resource_id: receipt_id,
          id: receipt_id
        },
        signature: 'test'
      )

      puts "   Evento creado: #{event.id}"
      puts "   Procesando..."

      begin
        # Fetch receipt data
        client = Loyverse::Client.new
        receipt_data = client.get_receipt(receipt_id)

        # Create LoyverseReceipt
        loyverse_receipt = LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_data['receipt_number']) do |r|
          r.receipt_number = receipt_data['receipt_number']
          r.receipt_type = receipt_data['receipt_type']
          r.total_money = receipt_data['total_money']
          r.total_tax = receipt_data['total_tax']
          r.receipt_data = receipt_data
          r.loyverse_created_at = receipt_data['created_at']
          r.synced_at = Time.current
        end

        puts "   ✅ Receipt sincronizado: #{loyverse_receipt.receipt_number}"

        # Create TurnClosure
        unless loyverse_receipt.converted?
          turn_closure = Loyverse::ReceiptMapper.new(loyverse_receipt).create_turn_closure
          puts "   ✅ TurnClosure creado: #{turn_closure.closure_number}"
        else
          puts "   ℹ️  Receipt ya convertido a TurnClosure"
        end

        event.mark_as_processed!
        puts "\n✅ Webhook procesado exitosamente"
      rescue => e
        event.mark_as_failed!(e)
        puts "\n❌ Error: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
    end

    desc "Simular webhook POST desde Loyverse"
    task :simulate, [:receipt_id] => :environment do |t, args|
      receipt_id = args[:receipt_id]

      unless receipt_id
        puts "❌ Error: Debes proporcionar un receipt_id"
        puts "   Uso: rails loyverse:webhooks:simulate[receipt_id]"
        exit 1
      end

      puts "🔔 Simulando webhook POST para receipt #{receipt_id}..."

      payload = {
        event_id: "test_#{Time.now.to_i}",
        event_type: 'RECEIPT_CREATED',
        resource_type: 'receipt',
        resource_id: receipt_id,
        id: receipt_id
      }

      puts "\nPayload:"
      puts JSON.pretty_generate(payload)
      puts "\nPara probar manualmente con curl:"
      puts "curl -X POST http://localhost:3000/api/v1/loyverse/webhooks \\"
      puts "  -H 'Content-Type: application/json' \\"
      puts "  -d '#{payload.to_json}'"
    end

    desc "Instrucciones para configurar ngrok (desarrollo local)"
    task :ngrok_setup do
      puts <<~INSTRUCTIONS

        ═══════════════════════════════════════════════════════════════
        📡 Configuración de Webhooks con ngrok (Desarrollo Local)
        ═══════════════════════════════════════════════════════════════

        Loyverse necesita una URL pública HTTPS para enviar webhooks.
        En desarrollo local, usa ngrok para crear un túnel:

        1️⃣  INSTALAR NGROK
        -------------------
        - Descarga desde: https://ngrok.com/download
        - O con Homebrew: brew install ngrok

        2️⃣  INICIAR SERVIDOR RAILS
        --------------------------
        bin/rails server -p 3000

        3️⃣  CREAR TÚNEL NGROK
        ---------------------
        ngrok http 3000

        Verás algo como:
        Forwarding: https://abc123.ngrok.io -> http://localhost:3000

        4️⃣  CONFIGURAR WEBHOOK EN LOYVERSE
        -----------------------------------
        rails loyverse:create_webhook[https://abc123.ngrok.io/api/v1/loyverse/webhooks]

        O manualmente en Loyverse Dashboard:
        - URL: https://abc123.ngrok.io/api/v1/loyverse/webhooks
        - Eventos: RECEIPT_CREATED, RECEIPT_UPDATED, SHIFT_CREATED

        5️⃣  VERIFICAR WEBHOOKS
        ----------------------
        # Listar webhooks configurados
        rails loyverse:list_webhooks

        # Ver eventos recibidos
        rails runner "puts LoyverseWebhookEvent.recent.limit(10).map(&:event_type)"

        # Monitorear logs
        tail -f log/development.log | grep Loyverse

        6️⃣  TESTEAR LOCALMENTE
        ----------------------
        # Simular un webhook
        rails loyverse:webhooks:simulate[receipt_id]

        # Procesar un receipt específico
        rails loyverse:webhooks:test_processing[receipt_id]

        ═══════════════════════════════════════════════════════════════
        🚀 PRODUCCIÓN
        ═══════════════════════════════════════════════════════════════

        Cuando tengas dominio:
        rails loyverse:create_webhook[https://tudominio.com/api/v1/loyverse/webhooks]

        ⚠️  IMPORTANTE:
        - ngrok URLs cambian cada vez que reinicias (gratis)
        - Plan pago de ngrok te da URLs fijas
        - En producción usa tu dominio real

      INSTRUCTIONS
    end

    desc "Listar eventos webhook recientes"
    task recent_events: :environment do
      events = LoyverseWebhookEvent.recent.limit(20)

      if events.empty?
        puts "📭 No hay eventos webhook registrados"
        puts "\nPara recibir webhooks:"
        puts "  1. Configura ngrok: rails loyverse:webhooks:ngrok_setup"
        puts "  2. Crea webhook: rails loyverse:create_webhook[TU_URL]"
        exit
      end

      puts "\n📬 Últimos 20 eventos webhook:\n\n"

      events.each do |event|
        status = if event.processed?
                   "✅"
                 elsif event.error_message.present?
                   "❌"
                 else
                   "⏳"
                 end

        puts "#{status} [#{event.created_at.strftime('%Y-%m-%d %H:%M:%S')}] #{event.event_type}"
        puts "   ID: #{event.id} | Resource: #{event.resource_id}"

        if event.error_message.present?
          puts "   Error: #{event.error_message.truncate(100)}"
        end
        puts ""
      end

      puts "\nResumen:"
      puts "  Total: #{events.count}"
      puts "  Procesados: #{events.select(&:processed?).count}"
      puts "  Fallidos: #{events.select { |e| e.error_message.present? }.count}"
      puts "  Pendientes: #{events.reject(&:processed?).count}"
    end

    desc "Limpiar eventos antiguos (mantener últimos 1000)"
    task cleanup: :environment do
      threshold = LoyverseWebhookEvent.order(created_at: :desc).limit(1000).last&.created_at

      if threshold
        deleted = LoyverseWebhookEvent.where('created_at < ?', threshold).delete_all
        puts "🗑️  Eliminados #{deleted} eventos antiguos"
        puts "   Manteniendo eventos desde: #{threshold}"
      else
        puts "ℹ️  Menos de 1000 eventos, no hay nada que limpiar"
      end
    end
  end
end
