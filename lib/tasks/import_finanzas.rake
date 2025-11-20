namespace :import do
  desc "Import financial data from finanzas-balcon.json"
  task finanzas: :environment do
    require 'json'

    file_path = Rails.root.join('../finanzas-balcon.json')
    unless File.exist?(file_path)
      puts "Error: finanzas-balcon.json not found at #{file_path}"
      exit 1
    end

    puts "📁 Loading finanzas-balcon.json..."
    data = JSON.parse(File.read(file_path))

    # Calculate real totals from expenses (not from resumen)
    total_invertido_real = data['gastos'].sum { |g| g['monto'] }
    gastos_daniel = data['gastos'].select { |g| ['yo', 'daniel'].include?(g['quienPago']) }
    gastos_raul = data['gastos'].select { |g| ['hermano', 'Raul', 'raul'].include?(g['quienPago']) }
    total_daniel = gastos_daniel.sum { |g| g['monto'] }
    total_raul = gastos_raul.sum { |g| g['monto'] }

    # Find or create users
    daniel = User.find_or_create_by!(email: 'daniel@balconcito.com') do |u|
      u.name = 'Daniel'
      u.password = 'password123'
      u.role = 'admin'
    end

    raul = User.find_or_create_by!(email: 'raul@balconcito.com') do |u|
      u.name = 'Raúl'
      u.password = 'password123'
      u.role = 'manager'
    end

    puts "✅ Users created/found: Daniel (#{daniel.id}), Raúl (#{raul.id})"

    # Create credit cards
    puts "\n💳 Creating credit cards..."

    banamex = CreditCard.find_or_create_by!(user: daniel, name: 'Banamex') do |card|
      card.bank_name = data['configTarjetas']['tarjeta1']['nombre']
      card.cut_day = data['configTarjetas']['tarjeta1']['corte']
      card.credit_limit = data['configTarjetas']['tarjeta1']['limite'] || 0
      card.is_active = true
      card.notes = 'Tarjeta principal para inversión inicial'
    end

    bancomer = CreditCard.find_or_create_by!(user: daniel, name: 'Bancomer') do |card|
      card.bank_name = data['configTarjetas']['tarjeta2']['nombre']
      card.cut_day = data['configTarjetas']['tarjeta2']['corte']
      card.credit_limit = data['configTarjetas']['tarjeta2']['limite'] || 0
      card.is_active = true
      card.notes = 'Tarjeta secundaria para equipamiento'
    end

    puts "✅ Credit cards created: Banamex (#{banamex.id}), Bancomer (#{bancomer.id})"

    # Create MSI purchases from pagosAMeses
    puts "\n📦 Creating MSI purchases..."

    msi_created = 0
    data['resumen']['pagosAMeses']['banamex']['compras'].each do |compra|
      purchase = CreditPurchase.find_or_create_by!(
        credit_card: banamex,
        user: daniel,
        concept: compra['concepto']
      ) do |p|
        p.total_amount = compra['monto']
        p.monthly_payment = compra['pagoMensual']
        p.total_months = compra['meses']
        p.purchase_date = Date.new(2025, 6, 17) # Fecha aproximada de inicio
        p.remaining_balance = compra['monto']
        p.paid_months = 0
        p.fully_paid = false
        p.notes = "Importado de finanzas1.json - Inversión inicial"
      end
      msi_created += 1
      puts "  ✓ #{purchase.concept} - #{purchase.total_months} meses - $#{purchase.total_amount}"
    end

    data['resumen']['pagosAMeses']['bancomer']['compras'].each do |compra|
      purchase = CreditPurchase.find_or_create_by!(
        credit_card: bancomer,
        user: daniel,
        concept: compra['concepto']
      ) do |p|
        p.total_amount = compra['monto']
        p.monthly_payment = compra['pagoMensual']
        p.total_months = compra['meses']
        p.purchase_date = Date.new(2025, 6, 17)
        p.remaining_balance = compra['monto']
        p.paid_months = 0
        p.fully_paid = false
        p.notes = "Importado de finanzas1.json - Inversión inicial"
      end
      msi_created += 1
      puts "  ✓ #{purchase.concept} - #{purchase.total_months} meses - $#{purchase.total_amount}"
    end

    puts "✅ Created #{msi_created} MSI purchases"

    # Create payment methods for historical data
    puts "\n💰 Creating payment methods for historical expenses..."

    pm_banamex = PaymentMethod.find_or_create_by!(user: daniel, name: 'Banamex (Histórico)') do |pm|
      pm.payment_type = 'personal_card'
      pm.requires_reimbursement = false # Inversión inicial, no requiere reembolso
      pm.is_active = false # Método histórico
      pm.description = 'Tarjeta Banamex - Inversión inicial'
    end

    pm_bancomer = PaymentMethod.find_or_create_by!(user: daniel, name: 'Bancomer (Histórico)') do |pm|
      pm.payment_type = 'personal_card'
      pm.requires_reimbursement = false
      pm.is_active = false
      pm.description = 'Tarjeta Bancomer - Inversión inicial'
    end

    pm_efectivo_daniel = PaymentMethod.find_or_create_by!(user: daniel, name: 'Efectivo Daniel (Histórico)') do |pm|
      pm.payment_type = 'personal_cash'
      pm.requires_reimbursement = false
      pm.is_active = false
      pm.description = 'Efectivo personal Daniel - Inversión inicial'
    end

    pm_efectivo_raul = PaymentMethod.find_or_create_by!(user: raul, name: 'Efectivo Raúl (Histórico)') do |pm|
      pm.payment_type = 'personal_cash'
      pm.requires_reimbursement = false
      pm.is_active = false
      pm.description = 'Efectivo personal Raúl - Inversión inicial'
    end

    puts "✅ Payment methods created"

    # Import expenses
    puts "\n📊 Importing historical expenses..."

    category_mapping = {
      'equipo' => 'equipment',
      'materiales' => 'construction_materials',
      'servicios' => 'utilities',
      'marketing' => 'marketing',
      'oficina' => 'office',
      'transporte' => 'transportation',
      'insumos' => 'initial_inventory',
      'otros' => 'others'
    }

    expenses_created = 0
    data['gastos'].each do |gasto|
      # Map payment method
      payment_method = case gasto['metodoPago']
      when 'tarjeta1'
        pm_banamex
      when 'tarjeta2'
        pm_bancomer
      when 'efectivo'
        if gasto['quienPago'] == 'hermano'
          pm_efectivo_raul
        else
          pm_efectivo_daniel
        end
      else
        pm_efectivo_daniel
      end

      # Map user who paid
      user_who_paid = (gasto['quienPago'] == 'hermano' || gasto['quienPago'] == 'Raul') ? raul : daniel

      # Map category
      category = category_mapping[gasto['categoria']] || 'otros'

      expense = Expense.find_or_create_by!(
        user: user_who_paid,
        expense_date: Date.parse(gasto['fecha']),
        description: gasto['concepto'],
        amount: gasto['monto']
      ) do |e|
        e.category = category
        e.payment_method = payment_method
        e.provider = gasto['notas']&.split(' - ')&.first
        e.requires_reimbursement = false # Inversión inicial
        e.reimbursed = false
      end

      expenses_created += 1
      print "\r  Importing expenses... #{expenses_created}/#{data['gastos'].length}"
    end

    puts "\n✅ Imported #{expenses_created} historical expenses"

    # Summary with calculated totals
    puts "\n" + "="*60
    puts "📈 IMPORT SUMMARY (CALCULATED FROM EXPENSES)"
    puts "="*60
    puts "Total Investment (REAL): $#{total_invertido_real.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "Total in JSON (wrong):   $#{data['resumen']['totalInvertido'].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "Difference:              $#{(total_invertido_real - data['resumen']['totalInvertido']).abs}"
    puts "\nDistribution by Person (REAL):"
    daniel_percentage = ((total_daniel.to_f / total_invertido_real) * 100).round(2)
    raul_percentage = ((total_raul.to_f / total_invertido_real) * 100).round(2)
    puts "  Daniel: $#{total_daniel.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} (#{daniel_percentage}%)"
    puts "  Raúl:   $#{total_raul.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} (#{raul_percentage}%)"
    puts "\nPayment Distribution:"
    gastos_banamex = data['gastos'].select { |g| g['metodoPago'] == 'tarjeta1' }.sum { |g| g['monto'] }
    gastos_bancomer = data['gastos'].select { |g| g['metodoPago'] == 'tarjeta2' }.sum { |g| g['monto'] }
    gastos_efectivo = data['gastos'].select { |g| g['metodoPago'] == 'efectivo' }.sum { |g| g['monto'] }
    gastos_transferencia = data['gastos'].select { |g| g['metodoPago'] == 'transferencia' }.sum { |g| g['monto'] }
    puts "  Banamex:       $#{gastos_banamex.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Bancomer:      $#{gastos_bancomer.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Cash:          $#{gastos_efectivo.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "  Transfer:      $#{gastos_transferencia.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
    puts "\nMonthly Commitments (MSI):"
    puts "  Banamex:  $#{data['resumen']['pagosAMeses']['banamex']['pagoMensual']}/month"
    puts "  Bancomer: $#{data['resumen']['pagosAMeses']['bancomer']['pagoMensual']}/month"
    total_monthly = data['resumen']['pagosAMeses']['banamex']['pagoMensual'] + data['resumen']['pagosAMeses']['bancomer']['pagoMensual']
    puts "  TOTAL:    $#{total_monthly}/month"
    puts "\nDatabase Records Created:"
    puts "  Users:            2"
    puts "  Credit Cards:     2"
    puts "  MSI Purchases:    #{msi_created}"
    puts "  Payment Methods:  4"
    puts "  Expenses:         #{expenses_created}"
    puts "="*60
    puts "\n✅ Import completed successfully!"
  end
end
