namespace :loyverse do
  desc "Sincronizar receipts de Loyverse para una fecha específica"
  task :sync_receipts, [ :start_date, :end_date ] => :environment do |t, args|
    start_date = args[:start_date]&.to_date || Date.today
    end_date = args[:end_date]&.to_date || start_date

    puts "🔄 Iniciando sincronización de Loyverse..."
    puts "   Período: #{start_date} a #{end_date}"

    service = Loyverse::SyncService.new(start_date: start_date, end_date: end_date)
    result = service.sync_receipts

    puts "\n✅ Sincronización completada:"
    puts "   - Receipts sincronizados: #{result[:receipts_synced]}"
    puts "   - TurnClosures creados: #{result[:turn_closures_created]}"

    if result[:errors].any?
      puts "\n⚠️  Errores (#{result[:errors].count}):"
      result[:errors].each do |error|
        puts "   - Receipt #{error[:receipt]}: #{error[:error]}"
      end
    end
  end

  desc "Sincronizar payment types de Loyverse"
  task sync_payment_types: :environment do
    puts "🔄 Sincronizando payment types de Loyverse..."

    service = Loyverse::SyncService.new
    result = service.sync_payment_types

    puts "✅ Payment types sincronizados: #{result[:payment_types_count]}"

    puts "\nMappings creados:"
    LoyversePaymentMapping.all.each do |mapping|
      status = mapping.mapped? ? "✅ Mapeado" : "⚠️  Sin mapear"
      method_name = mapping.payment_method&.name || "---"
      puts "   #{status} #{mapping.loyverse_payment_name} (#{mapping.loyverse_payment_type}) → #{method_name}"
    end
  end

  desc "Configurar token de API de Loyverse"
  task :configure, [ :api_token ] => :environment do |t, args|
    token = args[:api_token] || ENV["LOYVERSE_API_TOKEN"]

    if token.blank?
      puts "❌ Error: Debes proporcionar un token de API"
      puts "   Uso: rails loyverse:configure[tu_token]"
      puts "   O: LOYVERSE_API_TOKEN=tu_token rails loyverse:configure"
      exit 1
    end

    config = LoyverseConfig.instance
    config.api_token = token
    config.enable_sync!
    config.save!

    puts "✅ Token de Loyverse configurado correctamente"
    puts "   Sync habilitado: #{config.sync_active?}"
  end

  desc "Probar conexión con API de Loyverse"
  task test_connection: :environment do
    puts "🔌 Probando conexión con Loyverse API..."

    begin
      client = Loyverse::Client.new
      stores = client.get_stores

      puts "✅ Conexión exitosa!"
      puts "\nTiendas encontradas:"
      stores["stores"].each do |store|
        puts "   - #{store['name']} (#{store['id']})"
      end

      payment_types = client.get_payment_types
      puts "\nPayment types encontrados:"
      payment_types["payment_types"].each do |pt|
        puts "   - #{pt['name']} (#{pt['type']})"
      end
    rescue => e
      puts "❌ Error de conexión: #{e.message}"
      exit 1
    end
  end

  desc "Crear webhook en Loyverse"
  task :create_webhook, [ :url ] => :environment do |t, args|
    url = args[:url] || "#{ENV['APP_URL']}/api/v1/loyverse/webhooks"

    if url.blank?
      puts "❌ Error: Debes proporcionar una URL"
      puts "   Uso: rails loyverse:create_webhook[https://tu-api.com/api/v1/loyverse/webhooks]"
      exit 1
    end

    puts "🔌 Creando webhook en Loyverse..."
    puts "   URL: #{url}"

    begin
      client = Loyverse::Client.new
      events = [
        LoyverseWebhookEvent::RECEIPT_CREATED,
        LoyverseWebhookEvent::RECEIPT_UPDATED,
        LoyverseWebhookEvent::SHIFT_CREATED
      ]

      result = client.create_webhook(url, events)

      puts "✅ Webhook creado exitosamente!"
      puts "   ID: #{result['id']}"
      puts "   Eventos: #{events.join(', ')}"
    rescue => e
      puts "❌ Error: #{e.message}"
      exit 1
    end
  end

  desc "Listar webhooks configurados en Loyverse"
  task list_webhooks: :environment do
    puts "📋 Listando webhooks de Loyverse..."

    begin
      client = Loyverse::Client.new
      webhooks = client.get_webhooks

      if webhooks["webhooks"].empty?
        puts "   No hay webhooks configurados"
      else
        webhooks["webhooks"].each do |webhook|
          puts "\n   ID: #{webhook['id']}"
          puts "   URL: #{webhook['url']}"
          puts "   Eventos: #{webhook['events'].join(', ')}"
          puts "   Activo: #{webhook['active']}"
        end
      end
    rescue => e
      puts "❌ Error: #{e.message}"
      exit 1
    end
  end

  desc "Sincronizar shifts (turnos de caja) de Loyverse"
  task :sync_shifts, [ :start_date, :end_date ] => :environment do |t, args|
    start_date = args[:start_date]&.to_date || 1.week.ago.to_date
    end_date = args[:end_date]&.to_date || Date.today

    puts "🔄 Iniciando sincronización de Shifts (turnos)..."
    puts "   Período: #{start_date} a #{end_date}"

    service = Loyverse::SyncService.new(start_date: start_date, end_date: end_date)
    result = service.sync_shifts

    puts "\n✅ Sincronización de shifts completada:"
    puts "   - Shifts sincronizados: #{result[:shifts_synced]}"
    puts "   - TurnClosures creados: #{result[:turn_closures_created]}"

    if result[:errors].any?
      puts "\n⚠️  Errores (#{result[:errors].count}):"
      result[:errors].each do |error|
        puts "   - Shift #{error[:shift]}: #{error[:error]}"
      end
    end
  end

  desc "Sincronizar solo receipts (sin crear TurnClosures)"
  task :sync_receipts_only, [ :start_date, :end_date ] => :environment do |t, args|
    start_date = args[:start_date]&.to_date || Date.today
    end_date = args[:end_date]&.to_date || start_date

    puts "🔄 Iniciando sincronización de Receipts (sin crear TurnClosures)..."
    puts "   Período: #{start_date} a #{end_date}"

    service = Loyverse::SyncService.new(start_date: start_date, end_date: end_date)
    result = service.sync_receipts(create_turn_closures: false)

    puts "\n✅ Sincronización de receipts completada:"
    puts "   - Receipts sincronizados: #{result[:receipts_synced]}"

    if result[:errors].any?
      puts "\n⚠️  Errores (#{result[:errors].count}):"
      result[:errors].each do |error|
        puts "   - Receipt #{error[:receipt]}: #{error[:error]}"
      end
    end
  end

  desc "Sincronización completa (payment types + shifts de últimos 3 meses)"
  task full_sync: :environment do
    Rake::Task["loyverse:sync_payment_types"].invoke
    puts "\n" + ("=" * 60) + "\n\n"

    start_date = 3.months.ago.to_date
    end_date = Date.today

    # IMPORTANTE: Sincronizar SHIFTS, no receipts individuales
    # Los shifts son los turnos de caja que deben crear TurnClosures
    puts "ℹ️  NOTA: Sincronizando SHIFTS (turnos de caja), no receipts individuales"
    puts "    Cada shift = 1 turno del mesero = 1 TurnClosure"
    puts ""

    Rake::Task["loyverse:sync_shifts"].invoke(start_date, end_date)
  end
end
