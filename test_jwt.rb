require 'jwt'

puts "Testing JWT encoding and decoding..."
puts "=" * 50

# Simular lo que hace el backend
secret = Rails.application.credentials.secret_key_base
user_id = 1

# Generar token (como en auth_controller)
payload = {
  user_id: user_id,
  exp: 24.hours.from_now.to_i
}
token = JWT.encode(payload, secret, 'HS256')

puts "✅ Token generated:"
puts token[0..50] + "..."
puts

# Decodificar token (como en application_controller)
begin
  decoded = JWT.decode(token, secret, true, { algorithm: 'HS256' })
  puts "✅ Token decoded successfully:"
  puts "Payload: #{decoded[0]}"
  puts "User ID: #{decoded[0]['user_id']}"
rescue JWT::DecodeError => e
  puts "❌ JWT DecodeError: #{e.message}"
rescue JWT::ExpiredSignature => e
  puts "❌ JWT ExpiredSignature: #{e.message}"
rescue => e
  puts "❌ Unexpected error: #{e.class} - #{e.message}"
end

puts
puts "Secret key (first 30 chars): #{secret[0..30]}..."
