namespace :loyverse do
  desc "Sincronizar payment types desde Loyverse"
  task sync_payment_types: :environment do
    puts "🔄 Sincronizando payment types desde Loyverse..."

    # TODO: Implementar cuando se agregue integración Loyverse API
    # LoyverseService.sync_payment_types

    puts "⚠️  Esta funcionalidad requiere integración con Loyverse API (Milestone 4)"
    puts "   Por ahora, usa los payment methods que ya están en la base de datos"
  end

  desc "Sincronizar receipts desde Loyverse (uso: bin/rails loyverse:sync_receipts[2024-11-01,2024-11-18])"
  task :sync_receipts, [:start_date, :end_date] => :environment do |t, args|
    start_date = args[:start_date] || Date.today.beginning_of_month.to_s
    end_date = args[:end_date] || Date.today.to_s

    puts "🔄 Sincronizando receipts desde Loyverse..."
    puts "   Rango: #{start_date} a #{end_date}"

    # TODO: Implementar cuando se agregue integración Loyverse API
    # LoyverseService.sync_receipts(start_date, end_date)

    puts "⚠️  Esta funcionalidad requiere integración con Loyverse API (Milestone 4)"
    puts "   Por ahora, registra los cierres manualmente desde el frontend"
  end

  desc "Sincronización completa (payment types + receipts del mes actual)"
  task full_sync: :environment do
    puts "🔄 Iniciando sincronización completa con Loyverse..."

    # Sincronizar payment types
    Rake::Task['loyverse:sync_payment_types'].invoke

    # Sincronizar receipts del mes actual
    start_date = Date.today.beginning_of_month.to_s
    end_date = Date.today.to_s
    Rake::Task['loyverse:sync_receipts'].invoke(start_date, end_date)

    puts "✅ Sincronización completa finalizada"
  end

  desc "Verificar configuración de Loyverse API"
  task check_config: :environment do
    puts "🔍 Verificando configuración de Loyverse API..."

    api_token = ENV['LOYVERSE_API_TOKEN']

    if api_token.present?
      puts "✅ LOYVERSE_API_TOKEN configurado"
      puts "   Token: #{api_token[0..10]}..."
    else
      puts "❌ LOYVERSE_API_TOKEN no configurado"
      puts ""
      puts "Para configurar:"
      puts "  1. Obtén tu API token desde: https://r.loyverse.com/settings/api"
      puts "  2. Agrega a .env: LOYVERSE_API_TOKEN=tu_token_aqui"
      puts "  3. Reinicia el servidor"
    end

    puts ""
    puts "📝 Nota: La integración completa con Loyverse está planificada para Milestone 4"
  end

  desc "Mostrar estadísticas de sincronización"
  task stats: :environment do
    puts "📊 Estadísticas de datos:"
    puts ""
    puts "Cierres de turno registrados: #{TurnClosure.count}"
    puts "  - Este mes: #{TurnClosure.where('report_date >= ?', Date.today.beginning_of_month).count}"
    puts "  - Esta semana: #{TurnClosure.where('report_date >= ?', Date.today.beginning_of_week).count}"
    puts "  - Hoy: #{TurnClosure.where(report_date: Date.today).count}"
    puts ""
    puts "Gastos registrados: #{Expense.count}"
    puts "  - Este mes: #{Expense.where('expense_date >= ?', Date.today.beginning_of_month).count}"
    puts "  - Esta semana: #{Expense.where('expense_date >= ?', Date.today.beginning_of_week).count}"
    puts "  - Hoy: #{Expense.where(expense_date: Date.today).count}"
    puts ""
    puts "Métodos de pago activos: #{PaymentMethod.where(is_active: true).count}"
    puts "Reembolsos pendientes: #{Expense.pending_reimbursement.count} (Total: $#{Expense.pending_reimbursement.sum(:amount)})"
  end
end
