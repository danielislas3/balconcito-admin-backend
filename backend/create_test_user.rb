# Script para crear o actualizar el usuario Daniel con contraseña conocida
# Ejecutar: rails runner create_test_user.rb

puts "🔧 Creando/Actualizando usuario de prueba..."

# Buscar o crear usuario Daniel
user = User.find_or_initialize_by(email: 'daniel@balconcito.com')

# Actualizar atributos
user.name = 'Daniel'
user.role = 'admin'
user.password = 'password123'
user.password_confirmation = 'password123'

if user.save
  puts "✅ Usuario creado/actualizado exitosamente:"
  puts "   Email: #{user.email}"
  puts "   Name: #{user.name}"
  puts "   Role: #{user.role}"
  puts "   Password: password123"
  puts ""
  puts "🔐 Puedes hacer login con:"
  puts "   Email: daniel@balconcito.com"
  puts "   Password: password123"
else
  puts "❌ Error al crear usuario:"
  puts user.errors.full_messages.join("\n")
end
