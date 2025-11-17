# Limpiar datos existentes (solo en desarrollo/test)
if Rails.env.development? || Rails.env.test?
  puts "🗑️  Limpiando datos existentes..."
  ReimbursementExpense.destroy_all
  Reimbursement.destroy_all
  Expense.destroy_all
  TurnClosure.destroy_all
  PaymentMethod.destroy_all
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

# Crear métodos de pago
puts "💳 Creando métodos de pago..."

# Métodos del negocio (no requieren reembolso)
caja_chica_pm = PaymentMethod.create!(
  user: daniel,
  name: 'Caja Chica',
  payment_type: 'business_cash',
  requires_reimbursement: false,
  is_active: true,
  description: 'Efectivo disponible en caja chica del negocio'
)

boveda_pm = PaymentMethod.create!(
  user: daniel,
  name: 'Bóveda',
  payment_type: 'business_cash',
  requires_reimbursement: false,
  is_active: true,
  description: 'Efectivo guardado en la bóveda del negocio'
)

transferencia_pm = PaymentMethod.create!(
  user: daniel,
  name: 'Transferencia Negocio',
  payment_type: 'business_transfer',
  requires_reimbursement: false,
  is_active: true,
  description: 'Transferencias desde cuenta del negocio (Mercado Pago)'
)

# Métodos personales de Daniel (requieren reembolso)
daniel_card = PaymentMethod.create!(
  user: daniel,
  name: 'Tarjeta Personal Daniel',
  payment_type: 'personal_card',
  requires_reimbursement: true,
  is_active: true,
  description: 'Tarjeta de crédito personal de Daniel'
)

daniel_cash = PaymentMethod.create!(
  user: daniel,
  name: 'Efectivo Personal Daniel',
  payment_type: 'personal_cash',
  requires_reimbursement: true,
  is_active: true,
  description: 'Efectivo personal de Daniel'
)

# Métodos personales de Raúl (requieren reembolso)
raul_card = PaymentMethod.create!(
  user: raul,
  name: 'Tarjeta Personal Raúl',
  payment_type: 'personal_card',
  requires_reimbursement: true,
  is_active: true,
  description: 'Tarjeta de crédito personal de Raúl'
)

raul_cash = PaymentMethod.create!(
  user: raul,
  name: 'Efectivo Personal Raúl',
  payment_type: 'personal_cash',
  requires_reimbursement: true,
  is_active: true,
  description: 'Efectivo personal de Raúl'
)

puts "  ✅ #{PaymentMethod.count} métodos de pago creados"

puts "\n✅ Seeds completados!"
puts "   - #{User.count} usuarios: #{User.pluck(:name).join(', ')}"
puts "   - #{Account.count} cuentas: #{Account.pluck(:name).join(', ')}"
puts "   - #{PaymentMethod.count} métodos de pago: #{PaymentMethod.pluck(:name).join(', ')}"
puts "   - Balance total: $#{Account.total_balance}"
