# 🚀 Setup del Backend - Balconcito ERP

## Error 401 en Login - Solución

Si estás recibiendo un error 401 al intentar hacer login, es porque la base de datos no tiene usuarios creados o las gems no están instaladas.

## Pasos para Configurar el Backend

### 1. Instalar las Gems

```bash
cd backend
bundle install
```

### 2. Configurar la Base de Datos

```bash
# Crear la base de datos
rails db:create

# Ejecutar las migraciones
rails db:migrate
```

### 3. Ejecutar los Seeds (Crear Usuarios de Prueba)

```bash
rails db:seed
```

Este comando creará:
- ✅ 2 usuarios: Daniel y Raúl
- ✅ 3 cuentas: Mercado Pago, Bóveda, Caja Chica
- ✅ 7 métodos de pago (negocio y personales)

### 4. Iniciar el Servidor

```bash
rails server
# O en modo binding a todas las interfaces:
rails server -b 0.0.0.0
```

## Credenciales de Login

Después de ejecutar los seeds, puedes hacer login con:

**Usuario 1 (Daniel):**
- Email: `daniel@balconcito.com`
- Password: `password123`

**Usuario 2 (Raúl):**
- Email: `raul@balconcito.com`
- Password: `password123`

## Verificar que Funciona

### Opción 1: Desde el Frontend
1. Ve a `http://localhost:3001/login` (o el puerto donde esté el frontend)
2. Ingresa el email: `daniel@balconcito.com`
3. Ingresa el password: `password123`
4. Deberías ver el mensaje "¡Bienvenido Daniel!" y redirigir al dashboard

### Opción 2: Con cURL

```bash
# Test de login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "daniel@balconcito.com",
    "password": "password123"
  }'
```

Deberías recibir:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "daniel@balconcito.com",
    "name": "Daniel",
    "role": "admin"
  }
}
```

### Opción 3: Desde Rails Console

```bash
rails console

# Verificar usuarios
User.count
# => 2

User.all.pluck(:email, :name)
# => [["daniel@balconcito.com", "Daniel"], ["raul@balconcito.com", "Raúl"]]

# Verificar que la contraseña funciona
user = User.find_by(email: 'daniel@balconcito.com')
user.valid_password?('password123')
# => true
```

## Troubleshooting

### "Could not find rails-8.1.1 in locally installed gems"

**Causa:** Las gems no están instaladas
**Solución:**
```bash
bundle install
```

### "ActiveRecord::NoDatabaseError"

**Causa:** La base de datos no existe
**Solución:**
```bash
rails db:create
rails db:migrate
```

### "User not found" o "Invalid password"

**Causa:** Los seeds no se han ejecutado
**Solución:**
```bash
rails db:seed
```

### Error 500 en todas las peticiones

**Causa:** El ApplicationController no tenía los métodos de autenticación
**Solución:** Ya está arreglado en el último commit

### Error 401 en login con credenciales correctas

**Causas posibles:**
1. Los seeds no se ejecutaron → Ejecuta `rails db:seed`
2. La contraseña es diferente → Usa `password123`
3. El usuario no existe → Verifica con `rails console` y `User.count`

## Datos de Prueba Creados por Seeds

### Usuarios
```ruby
Daniel (admin)
  - Email: daniel@balconcito.com
  - Password: password123

Raúl (admin)
  - Email: raul@balconcito.com
  - Password: password123
```

### Cuentas
```ruby
Mercado Pago (digital) - Balance: $0
Bóveda (physical_cash) - Balance: $0
Caja Chica (petty_cash) - Balance: $1,000
```

### Métodos de Pago

**Del Negocio (no requieren reembolso):**
- Caja Chica
- Bóveda
- Transferencia Negocio

**Personales de Daniel (requieren reembolso):**
- Tarjeta Personal Daniel
- Efectivo Personal Daniel

**Personales de Raúl (requieren reembolso):**
- Tarjeta Personal Raúl
- Efectivo Personal Raúl

## Comandos Útiles

```bash
# Ver logs del servidor
tail -f log/development.log

# Resetear la base de datos (CUIDADO: Borra todo)
rails db:reset
# Equivalente a: drop + create + migrate + seed

# Solo volver a ejecutar seeds (sin borrar)
rails db:seed

# Verificar rutas
rails routes | grep auth

# Abrir consola de Rails
rails console
```

## Puertos por Defecto

- **Backend (Rails):** `http://localhost:3000`
- **Frontend (Nuxt):** `http://localhost:3001` (o el que configuraste)

## Siguiente Paso

Una vez que hayas ejecutado todos estos pasos:
1. El backend debería estar corriendo en `http://localhost:3000`
2. Prueba el login desde el frontend
3. Si funciona, verás el dashboard con tus datos

## Estructura de la Base de Datos

Después de ejecutar las migraciones y seeds:

```
users (2 registros)
├── id: 1, email: daniel@balconcito.com, name: Daniel, role: admin
└── id: 2, email: raul@balconcito.com, name: Raúl, role: admin

accounts (3 registros)
├── Mercado Pago (digital) - $0
├── Bóveda (physical_cash) - $0
└── Caja Chica (petty_cash) - $1,000

payment_methods (7 registros)
├── Caja Chica (business_cash)
├── Bóveda (business_cash)
├── Transferencia Negocio (business_transfer)
├── Tarjeta Personal Daniel (personal_card) - requires_reimbursement: true
├── Efectivo Personal Daniel (personal_cash) - requires_reimbursement: true
├── Tarjeta Personal Raúl (personal_card) - requires_reimbursement: true
└── Efectivo Personal Raúl (personal_cash) - requires_reimbursement: true

turn_closures (0 registros)
expenses (0 registros)
reimbursements (0 registros)
```

## Resumen Rápido

```bash
# Setup completo en 4 comandos:
cd backend
bundle install
rails db:create db:migrate db:seed
rails server
```

Luego usa las credenciales:
- Email: `daniel@balconcito.com`
- Password: `password123`

¡Listo! 🎉
