namespace :loyverse do
  desc "Debug: Mostrar estructura de un receipt de Loyverse"
  task debug_receipt: :environment do
    puts "🔍 Obteniendo un receipt de ejemplo de Loyverse..."

    begin
      client = Loyverse::Client.new
      response = client.get_receipts(limit: 1)

      if response['receipts']&.any?
        receipt = response['receipts'].first
        puts "\n📋 Estructura del receipt:"
        puts JSON.pretty_generate(receipt)

        puts "\n🔑 Campos importantes:"
        puts "  Receipt Number (usado como ID): #{receipt['receipt_number']}"
        puts "  Type: #{receipt['receipt_type']}"
        puts "  Created At: #{receipt['created_at']}"
        puts "  Total Money: #{receipt['total_money']}"
        puts ""
        puts "  ℹ️  Nota: Loyverse no devuelve 'id' en GET /receipts"
        puts "           Usamos 'receipt_number' como identificador único"
      else
        puts "❌ No se encontraron receipts"
      end
    rescue => e
      puts "❌ Error: #{e.class} - #{e.message}"
      puts e.backtrace.first(5)
    end
  end

  desc "Debug: Ver payment mappings actuales"
  task debug_mappings: :environment do
    puts "🔍 Payment Mappings Actuales:"
    puts ""

    LoyversePaymentMapping.all.each do |mapping|
      status = mapping.mapped? ? "✅ Mapeado" : "⚠️  Sin mapear"
      method_name = mapping.payment_method&.name || "---"

      puts "#{status}"
      puts "  Loyverse: #{mapping.loyverse_payment_name} (#{mapping.loyverse_payment_type})"
      puts "  ID Loyverse: #{mapping.loyverse_payment_type_id}"
      puts "  → PaymentMethod: #{method_name}"
      puts ""
    end

    puts "\n📊 Payment Methods Disponibles:"
    PaymentMethod.all.each do |pm|
      puts "  [#{pm.id}] #{pm.name} (#{pm.payment_type})"
    end
  end
end
