# Guía de Configuración: Integración Loyverse

Esta guía te llevará paso a paso para configurar la integración completa con Loyverse POS, automatizando el cierre de caja y la creación de TurnClosures.

## 📋 Tabla de Contenidos

- [Prerrequisitos](#prerrequisitos)
- [1. Configuración Inicial](#1-configuración-inicial)
- [2. Obtener API Token de Loyverse](#2-obtener-api-token-de-loyverse)
- [3. Configurar la Aplicación](#3-configurar-la-aplicación)
- [4. Sincronizar Payment Types](#4-sincronizar-payment-types)
- [5. Configurar Webhook](#5-configurar-webhook)
- [6. Pruebas](#6-pruebas)
- [Troubleshooting](#troubleshooting)

---

## Prerrequisitos

- ✅ Rails 8.1.1 configurado
- ✅ PostgreSQL corriendo (Docker o local)
- ✅ Cuenta activa en Loyverse POS
- ✅ Acceso al backend de Loyverse
- ✅ URL pública para recibir webhooks (ngrok, túnel, o dominio en producción)

---

## 1. Configuración Inicial

### 1.1 Ejecutar Migraciones

```bash
cd backend
rails db:migrate
```

Esto creará las siguientes tablas:
- `loyverse_configs` - Configuración del API token
- `loyverse_webhook_events` - Log de webhooks recibidos
- `loyverse_receipts` - Tickets/ventas de Loyverse
- `loyverse_shifts` - Turnos cerrados
- `loyverse_payment_mappings` - Mapeo de métodos de pago

### 1.2 Verificar Instalación de Gemas

```bash
bundle install
```

Debe incluir la gema `http (~> 5.0)` para hacer requests a la API de Loyverse.

---

## 2. Obtener API Token de Loyverse

### Paso 1: Acceder al Backend de Loyverse

1. Ve a [https://r.loyverse.com/dashboard](https://r.loyverse.com/dashboard)
2. Inicia sesión con tu cuenta de Loyverse

### Paso 2: Navegar a API Settings

1. Click en **Settings** (⚙️ en el menú lateral)
2. Selecciona **Integrations**
3. Busca **Developer Tools** o **API Access**

### Paso 3: Generar Access Token

1. Click en **Create new token** o **Generate API token**
2. Dale un nombre descriptivo: "Balconcito Admin API"
3. Selecciona los permisos necesarios:
   - ✅ **Read receipts**
   - ✅ **Read shifts**
   - ✅ **Read payment types**
   - ✅ **Read stores**
   - ✅ **Read employees**
4. Click en **Generate**
5. **IMPORTANTE**: Copia el token inmediatamente (solo se muestra una vez)

El token se verá algo así:
```
lyv_abc123def456ghi789jkl012mno345pqr678stu901
```

---

## 3. Configurar la Aplicación

### 3.1 Configurar API Token

Ejecuta el siguiente comando, reemplazando `TU_TOKEN_AQUI` con tu token real:

```bash
rails loyverse:configure[TU_TOKEN_AQUI]
```

**Ejemplo:**
```bash
rails loyverse:configure[lyv_abc123def456ghi789jkl012mno345pqr678stu901]
```

Deberías ver:
```
🔧 Configurando Loyverse...
   API Token: lyv_abc***********
✅ Configuración guardada exitosamente!
   ID: 1
   Sync habilitado: true
```

### 3.2 Probar Conexión

```bash
rails loyverse:test_connection
```

Salida esperada:
```
🔌 Probando conexión a Loyverse API...

✅ Conexión exitosa!
📊 Información de la cuenta:
   - Tiendas encontradas: 1
   - Payment types configurados: 3
   - API funcionando correctamente

💡 Siguiente paso: Sincronizar payment types
   rails loyverse:sync_payment_types
```

Si ves errores:
- **401 Unauthorized**: Token inválido o expirado
- **Network error**: Verifica tu conexión a internet
- **Rate limit exceeded**: Espera 1 minuto (límite: 60 requests/min)

---

## 4. Sincronizar Payment Types

Los **Payment Types** son los métodos de pago configurados en Loyverse (Efectivo, Tarjeta, Transferencia, etc.).

### 4.1 Sincronizar desde Loyverse

```bash
rails loyverse:sync_payment_types
```

Salida esperada:
```
🔄 Sincronizando payment types desde Loyverse...

📥 Payment types encontrados en Loyverse:
   1. Efectivo (CASH)
   2. Tarjeta (CARD)
   3. Transferencia QR (CUSTOM)

✅ 3 payment types sincronizados
💡 Verifica los mapeos en: GET /api/v1/loyverse/payment_mappings
```

### 4.2 Verificar Mapeos

Los payment types de Loyverse deben mapearse a tus `PaymentMethods` en la base de datos:

**Mapeo recomendado:**
- Loyverse `CASH` → PaymentMethod `cash` (Efectivo)
- Loyverse `CARD` → PaymentMethod `card` (Tarjeta)
- Loyverse `CUSTOM` → PaymentMethod `transfer` (Transferencia)

El mapeo automático se hace basado en el `type` del payment type de Loyverse.

---

## 5. Configurar Webhook

Los webhooks permiten que Loyverse notifique a tu aplicación cuando ocurre un evento (ej. se cierra un turno).

### 5.1 Preparar URL Pública

#### Opción A: Desarrollo con ngrok

```bash
# Instalar ngrok (si no lo tienes)
brew install ngrok  # macOS
# o
snap install ngrok  # Linux

# Iniciar túnel
ngrok http 3000
```

Copia la URL que te da ngrok:
```
Forwarding  https://abc123.ngrok.io -> http://localhost:3000
```

Tu webhook URL será:
```
https://abc123.ngrok.io/api/v1/loyverse/webhooks
```

#### Opción B: Producción

Si ya tienes dominio en producción:
```
https://tu-dominio.com/api/v1/loyverse/webhooks
```

### 5.2 Registrar Webhook en Loyverse

```bash
rails loyverse:create_webhook[https://abc123.ngrok.io/api/v1/loyverse/webhooks]
```

**Ejemplo real:**
```bash
rails loyverse:create_webhook[https://abc123.ngrok.io/api/v1/loyverse/webhooks]
```

Salida esperada:
```
🔌 Creando webhook en Loyverse...
   URL: https://abc123.ngrok.io/api/v1/loyverse/webhooks

✅ Webhook creado exitosamente!
   ID: wh_xyz789abc123
   Eventos: RECEIPT_CREATED, RECEIPT_UPDATED, shifts.create
   Status: active

🎯 Tu aplicación ahora recibirá notificaciones cuando:
   - Se cree o actualice un ticket (receipt)
   - Se cierre un turno (shift)
```

### 5.3 Verificar Webhooks Activos

```bash
rails loyverse:list_webhooks
```

Salida esperada:
```
📋 Webhooks configurados en Loyverse:

1. Webhook ID: wh_xyz789abc123
   URL: https://abc123.ngrok.io/api/v1/loyverse/webhooks
   Eventos: ["RECEIPT_CREATED", "RECEIPT_UPDATED", "shifts.create"]
   Status: active
   Creado: 2025-11-17 10:30:45 UTC

Total: 1 webhook(s)
```

---

## 6. Pruebas

### 6.1 Prueba Manual: Cerrar un Turno

1. **En Loyverse POS:**
   - Abre un turno (si no hay uno abierto)
   - Realiza algunas ventas de prueba
   - Cierra el turno: **Menu → Shift Management → Close Shift**
   - Ingresa el efectivo en caja
   - Confirma el cierre

2. **En tu aplicación:**
   - Monitorea los logs:
     ```bash
     tail -f log/development.log
     ```

   - Deberías ver:
     ```
     🔔 Webhook SHIFT_CREATED recibido: shift-uuid-123
     🔄 Procesando shift shift-uuid-123
       📥 Obteniendo datos del shift...
       ✅ Shift creado/actualizado
       📥 Obteniendo receipts del turno...
       📊 Encontrados 5 receipts
       ✅ 5 receipts asociados al shift
       💰 Creando TurnClosure...
       📊 Totales calculados:
          - Efectivo: $1500.00
          - Tarjeta: $2300.50
          - Transferencia: $450.00
          - Total: $4250.50
       ✅ TurnClosure #20251117-001 creado
     ✅ Shift procesado: TurnClosure #20251117-001
     ```

3. **Verificar en la base de datos:**
   ```bash
   rails console
   ```

   ```ruby
   # Verificar que se creó el TurnClosure
   TurnClosure.last
   # => #<TurnClosure id: 1, closure_number: "20251117-001",
   #     cash_collected: 1500.0, card_income_gross: 2300.5, ...>

   # Verificar que se creó el shift
   LoyverseShift.last
   # => #<LoyverseShift id: 1, loyverse_id: "shift-uuid-123",
   #     gross_sales: 4250.5, ...>

   # Verificar receipts asociados
   LoyverseShift.last.loyverse_receipts.count
   # => 5
   ```

### 6.2 Verificar Totales

Los totales deben coincidir **exactamente** con Loyverse:

```ruby
shift = LoyverseShift.last
shift.calculate_payment_totals

# => {
#   cash: 1500.0,
#   card: 2300.5,
#   custom: 450.0,
#   total: 4250.5
# }

# Comparar con TurnClosure creado
turn_closure = shift.turn_closure
turn_closure.cash_collected     # => 1500.0
turn_closure.card_income_gross  # => 2300.5
turn_closure.transfer_income_gross # => 450.0
```

### 6.3 Verificar Actualización de Cuentas

```ruby
# Bóveda (efectivo)
Account.find_by(account_type: 'vault').balance
# => Debería aumentar en 1500.0

# Mercado Pago (tarjetas + transferencias)
Account.find_by(account_type: 'bank', name: 'Mercado Pago').balance
# => Debería aumentar en 2750.5 (2300.5 + 450.0)
```

---

## Troubleshooting

### Error: "Invalid API token"

**Causa:** Token inválido o expirado

**Solución:**
1. Genera un nuevo token en Loyverse
2. Reconfigura:
   ```bash
   rails loyverse:configure[NUEVO_TOKEN]
   ```

---

### Error: "Rate limit exceeded"

**Causa:** Superaste el límite de 60 requests/minuto

**Solución:**
- Espera 60 segundos
- Reduce la frecuencia de sincronizaciones manuales

---

### Webhook no recibe eventos

**Causa:** URL no accesible o webhook no registrado

**Diagnóstico:**
```bash
# 1. Verificar que el webhook esté registrado
rails loyverse:list_webhooks

# 2. Probar URL manualmente
curl -X POST https://TU_URL/api/v1/loyverse/webhooks \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": "test-123",
    "event_type": "shifts.create",
    "resource_id": "test-shift-id"
  }'
```

**Solución:**
- Verifica que ngrok esté corriendo
- Confirma que la URL sea accesible públicamente
- Re-registra el webhook si es necesario

---

### Totales no coinciden con Loyverse

**Causa:** Receipts no están siendo asociados correctamente al shift

**Diagnóstico:**
```ruby
shift = LoyverseShift.last
shift.loyverse_receipts.count  # ¿Cuántos receipts tiene asociados?

# Ver si hay receipts sin asociar
LoyverseReceipt.where(loyverse_shift_id: nil).count
```

**Solución:**
- Verifica el rango de tiempo: `shift.opened_at` a `shift.closed_at`
- Confirma que los receipts estén en ese rango
- Re-procesa el shift manualmente:
  ```ruby
  Loyverse::ShiftProcessor.new(shift.loyverse_id).process
  ```

---

### Shift procesado pero TurnClosure no se crea

**Causa:** Error en `ShiftProcessor#create_turn_closure`

**Diagnóstico:**
```bash
# Ver logs de errores
tail -f log/development.log | grep ERROR

# Ver webhook events fallidos
rails console
LoyverseWebhookEvent.failed.last.error_message
```

**Solución:**
- Revisa que existan las cuentas necesarias:
  ```ruby
  Account.find_by(account_type: 'vault')  # Debe existir
  Account.find_by(account_type: 'bank', name: 'Mercado Pago')  # Debe existir
  ```

- Re-intenta el procesamiento:
  ```ruby
  event = LoyverseWebhookEvent.failed.last
  event.retry_processing!
  ```

---

## Sincronización Manual (Opcional)

Si quieres sincronizar datos históricos manualmente:

### Sincronizar Receipts de un Rango de Fechas

```bash
rails loyverse:sync_receipts['2025-11-01','2025-11-17']
```

Esto traerá todos los receipts entre esas fechas y creará TurnClosures si no existen.

---

## API Endpoints Disponibles

Una vez configurado, tendrás acceso a:

### Webhooks
- `POST /api/v1/loyverse/webhooks` - Recibir webhooks de Loyverse
- `GET /api/v1/loyverse/webhooks` - Listar webhooks recibidos
- `POST /api/v1/loyverse/webhooks/:id/retry` - Re-procesar webhook fallido

### Receipts
- `GET /api/v1/loyverse/receipts` - Listar receipts sincronizados
- `GET /api/v1/loyverse/receipts/:id` - Ver receipt individual
- `POST /api/v1/loyverse/receipts/sync` - Sincronizar manualmente

### Shifts
- `GET /api/v1/loyverse/shifts` - Listar shifts cerrados
- `GET /api/v1/loyverse/shifts/:id` - Ver shift individual

### Configuration
- `GET /api/v1/loyverse/config` - Ver configuración actual
- `PATCH /api/v1/loyverse/config` - Actualizar configuración

### Payment Mappings
- `GET /api/v1/loyverse/payment_mappings` - Ver mapeos
- `POST /api/v1/loyverse/payment_mappings/sync` - Sincronizar payment types
- `PATCH /api/v1/loyverse/payment_mappings/:id` - Actualizar mapeo

---

## Próximos Pasos

Una vez que la integración esté funcionando:

1. ✅ Monitorea los primeros turnos cerrados
2. ✅ Verifica que los totales coincidan 100% con Loyverse
3. ✅ Configura alertas si hay faltantes de efectivo
4. ✅ Revisa el dashboard de métricas financieras
5. ✅ Capacita al personal sobre el nuevo flujo automatizado

---

## Soporte

Si tienes problemas que no están cubiertos aquí:

1. Revisa los logs: `tail -f log/development.log`
2. Consulta la documentación de Loyverse API: https://help.loyverse.com/help/loyverse-api
3. Revisa los archivos de documentación:
   - `LOYVERSE_INTEGRATION.md` - Detalles técnicos de la API
   - `LOYVERSE_WEBHOOKS_STRATEGY.md` - Análisis de webhooks
   - `LOYVERSE_SHIFTS_IMPLEMENTATION.md` - Implementación de shifts

---

**Última actualización:** 17 de noviembre, 2025
**Versión de la integración:** 1.0.0
