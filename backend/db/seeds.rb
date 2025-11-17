# Limpiar datos existentes (solo en desarrollo/test)
if Rails.env.development? || Rails.env.test?
  puts "🗑️  Limpiando datos existentes..."
  ReimbursementExpense.destroy_all
  Reimbursement.destroy_all
  Expense.destroy_all
  TurnClosure.destroy_all
  Account.destroy_all
  User.destroy_all
end

# Crear usuarios
puts "👥 Creando usuarios..."
daniel = User.create!(
  email: 'daniel@balconcito.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Daniel',
  role: 'admin'
)

raul = User.create!(
  email: 'raul@balconcito.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Raúl',
  role: 'admin'
)

puts "  ✅ #{User.count} usuarios creados"

# Crear cuentas
puts "🏦 Creando cuentas..."
mercadopago = Account.create!(
  name: 'Mercado Pago',
  account_type: 'digital',
  current_balance: 0.0,
  description: 'Cuenta digital para transferencias y pagos con tarjeta'
)

boveda = Account.create!(
  name: 'Bóveda',
  account_type: 'physical_cash',
  current_balance: 0.0,
  description: 'Efectivo guardado físicamente'
)

caja_chica = Account.create!(
  name: 'Caja Chica',
  account_type: 'petty_cash',
  current_balance: 1000.0,
  description: 'Fondo fijo de $1,000 + ventas del día'
)

puts "  ✅ #{Account.count} cuentas creadas"

puts "\n✅ Seeds completados!"
puts "   - #{User.count} usuarios: #{User.pluck(:name).join(', ')}"
puts "   - #{Account.count} cuentas: #{Account.pluck(:name).join(', ')}"
puts "   - Balance total: $#{Account.total_balance}"
