# Integración de Webhooks con Loyverse

Este documento describe cómo configurar y usar webhooks de Loyverse para sincronización en tiempo real.

## 📋 Tabla de Contenidos

- [¿Qué son los Webhooks?](#qué-son-los-webhooks)
- [Configuración Local (Desarrollo)](#configuración-local-desarrollo)
- [Configuración en Producción](#configuración-en-producción)
- [Eventos Soportados](#eventos-soportados)
- [Testing y Debugging](#testing-y-debugging)
- [Solución de Problemas](#solución-de-problemas)

---

## ¿Qué son los Webhooks?

Los webhooks permiten que Loyverse notifique a tu aplicación en tiempo real cuando ocurren eventos:

- ✅ **Nuevo receipt creado** → Se crea automáticamente un TurnClosure
- ✅ **Receipt actualizado** → Se actualiza el TurnClosure correspondiente
- ✅ **Shift cerrado** → Se procesa el shift completo

**Ventajas:**
- Sincronización instantánea (no necesitas ejecutar rake tasks manualmente)
- Menor carga en la API de Loyverse
- Datos siempre actualizados

---

## Configuración Local (Desarrollo)

### Requisitos

- Rails server corriendo en `localhost:3000`
- [ngrok](https://ngrok.com) instalado
- Token de API de Loyverse configurado

### Paso 1: Instalar ngrok

```bash
# macOS (Homebrew)
brew install ngrok

# O descarga desde https://ngrok.com/download
```

### Paso 2: Iniciar Rails

```bash
cd backend
bin/rails server -p 3000
```

### Paso 3: Crear túnel ngrok

En otra terminal:

```bash
ngrok http 3000
```

Verás algo como:

```
Forwarding: https://abc123.ngrok.io -> http://localhost:3000
```

**⚠️ IMPORTANTE:** Esta URL cambia cada vez que reinicias ngrok (plan gratuito).

### Paso 4: Configurar webhook en Loyverse

```bash
# Usando la URL de ngrok
rails loyverse:create_webhook[https://abc123.ngrok.io/api/v1/loyverse/webhooks]
```

### Paso 5: Verificar configuración

```bash
# Ver webhooks configurados
rails loyverse:list_webhooks

# Monitorear eventos recibidos
rails loyverse:webhooks:recent_events

# Ver logs en tiempo real
tail -f log/development.log | grep Loyverse
```

---

## Configuración en Producción

### Requisitos

- Dominio con HTTPS (Loyverse requiere SSL)
- Aplicación Rails desplegada y accesible públicamente

### Configuración

```bash
# En producción, usa tu dominio real
RAILS_ENV=production rails loyverse:create_webhook[https://tudominio.com/api/v1/loyverse/webhooks]
```

### Verificación

```bash
# Verificar webhooks activos
RAILS_ENV=production rails loyverse:list_webhooks

# Monitorear eventos
RAILS_ENV=production rails loyverse:webhooks:recent_events
```

---

## Eventos Soportados

Tu aplicación procesa los siguientes eventos de Loyverse:

| Evento | Descripción | Acción |
|--------|-------------|--------|
| `RECEIPT_CREATED` | Nuevo ticket de venta | Crea LoyverseReceipt y TurnClosure |
| `RECEIPT_UPDATED` | Ticket modificado | Actualiza LoyverseReceipt |
| `SHIFT_CREATED` | Turno creado/cerrado | Procesa shift completo con ShiftProcessor |

### Flujo de procesamiento

```
Loyverse → POST /api/v1/loyverse/webhooks → LoyverseWebhookEvent
                                            ↓
                                      process_webhook()
                                            ↓
                            ┌───────────────┴───────────────┐
                            ↓                               ↓
                    RECEIPT_CREATED                  SHIFT_CREATED
                            ↓                               ↓
                  Fetch receipt via API             Fetch shift via API
                            ↓                               ↓
                  Create LoyverseReceipt         Process with ShiftProcessor
                            ↓                               ↓
                    Create TurnClosure              Create TurnClosure(s)
```

---

## Testing y Debugging

### Simular webhook localmente

```bash
# Simular webhook para un receipt específico
rails loyverse:webhooks:test_processing[receipt_id]

# Ver payload de ejemplo
rails loyverse:webhooks:simulate[receipt_id]
```

### Testear con curl

```bash
curl -X POST http://localhost:3000/api/v1/loyverse/webhooks \
  -H 'Content-Type: application/json' \
  -d '{
    "event_id": "test_123",
    "event_type": "RECEIPT_CREATED",
    "resource_type": "receipt",
    "resource_id": "abc-123",
    "id": "abc-123"
  }'
```

### Ver eventos recientes

```bash
# Últimos 20 eventos
rails loyverse:webhooks:recent_events

# Desde consola Rails
rails console
> LoyverseWebhookEvent.recent.limit(10).each { |e| puts "#{e.event_type} - #{e.processed? ? '✅' : '❌'}" }
```

### Reintentar evento fallido

```bash
# Desde consola
rails console
> event = LoyverseWebhookEvent.find(123)
> event.retry_processing!

# Via API (requiere autenticación)
curl -X POST http://localhost:3000/api/v1/loyverse/webhooks/123/retry \
  -H "Authorization: Bearer YOUR_JWT"
```

### Limpiar eventos antiguos

```bash
# Mantener solo últimos 1000 eventos
rails loyverse:webhooks:cleanup
```

---

## Solución de Problemas

### Webhook no se recibe

**Problema:** Loyverse no está enviando webhooks

**Soluciones:**

1. Verificar que el webhook esté activo:
   ```bash
   rails loyverse:list_webhooks
   ```

2. Verificar URL es accesible públicamente:
   ```bash
   curl https://tu-url/api/v1/loyverse/webhooks
   # Debe responder 200 OK
   ```

3. Verificar logs de ngrok (desarrollo):
   - Abre http://localhost:4040 para ver requests entrantes

4. Verificar que Loyverse tenga permisos para enviar webhooks

---

### Webhook recibido pero falla procesamiento

**Problema:** Evento se guarda pero marca como fallido

**Soluciones:**

1. Ver error específico:
   ```bash
   rails console
   > LoyverseWebhookEvent.failed.last.error_message
   ```

2. Reintentar manualmente:
   ```bash
   > event = LoyverseWebhookEvent.failed.last
   > event.retry_processing!
   ```

3. Verificar que receipt_id existe en Loyverse:
   ```bash
   rails runner "puts Loyverse::Client.new.get_receipt('RECEIPT_ID').inspect"
   ```

---

### ngrok URL cambia constantemente

**Problema:** La URL de ngrok cambia cada vez que lo reinicias

**Soluciones:**

1. **Opción 1:** Cuenta paga de ngrok (URL fija)
   ```bash
   ngrok http 3000 --domain=tu-dominio.ngrok.io
   ```

2. **Opción 2:** Usar servicio similar (localtunnel, serveo)

3. **Opción 3:** Script para re-configurar webhook automáticamente:
   ```bash
   #!/bin/bash
   # update_webhook.sh
   NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
   rails loyverse:create_webhook[$NGROK_URL/api/v1/loyverse/webhooks]
   ```

---

### Eventos procesados dos veces

**Problema:** Loyverse reenvía webhooks si no recibe respuesta 200 rápido

**Solución:**

El código ya maneja esto usando `find_or_create_by!` con `loyverse_id` único:

```ruby
# En WebhooksController
LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_data['receipt_number']) do |r|
  # Solo se ejecuta si es nuevo
end
```

---

## Endpoints de Webhooks

### POST /api/v1/loyverse/webhooks

Recibe eventos de Loyverse (público, sin autenticación JWT)

**Headers:**
- `Content-Type: application/json`
- `X-Loyverse-Webhook-Signature` (opcional, para validación)

**Body:**
```json
{
  "event_id": "evt_123",
  "event_type": "RECEIPT_CREATED",
  "resource_type": "receipt",
  "resource_id": "abc-123",
  "id": "abc-123"
}
```

**Response:** `200 OK` (vacío)

---

### GET /api/v1/loyverse/webhooks

Lista eventos recibidos (requiere autenticación)

**Headers:**
- `Authorization: Bearer YOUR_JWT`

**Response:**
```json
[
  {
    "id": 1,
    "event_id": "evt_123",
    "event_type": "RECEIPT_CREATED",
    "processed": true,
    "processed_at": "2025-11-18T20:00:00Z",
    "error_message": null,
    "created_at": "2025-11-18T20:00:00Z"
  }
]
```

---

### POST /api/v1/loyverse/webhooks/:id/retry

Reintentar procesamiento de evento fallido (requiere autenticación)

---

## Rake Tasks de Webhooks

| Task | Descripción |
|------|-------------|
| `loyverse:webhooks:ngrok_setup` | Muestra instrucciones de configuración |
| `loyverse:webhooks:test_processing[id]` | Procesar receipt específico localmente |
| `loyverse:webhooks:simulate[id]` | Mostrar payload de ejemplo |
| `loyverse:webhooks:recent_events` | Listar últimos eventos |
| `loyverse:webhooks:cleanup` | Limpiar eventos antiguos |

---

## Modelo de Datos

### LoyverseWebhookEvent

```ruby
# Campos
event_id       # ID único del evento (de Loyverse)
event_type     # RECEIPT_CREATED, RECEIPT_UPDATED, SHIFT_CREATED
payload        # JSONB con datos completos del evento
signature      # Firma de Loyverse (para validación)
processed      # Boolean, ¿fue procesado?
processed_at   # Timestamp de procesamiento
error_message  # Mensaje de error si falló

# Métodos útiles
event.supported?              # ¿Es un evento que procesamos?
event.mark_as_processed!      # Marcar como procesado
event.mark_as_failed!(error)  # Marcar como fallido
event.retry_processing!       # Reintentar
```

---

## Monitoreo en Producción

### Métricas a monitorear

1. **Tasa de éxito de webhooks:**
   ```ruby
   total = LoyverseWebhookEvent.count
   success = LoyverseWebhookEvent.processed.count
   success_rate = (success.to_f / total * 100).round(2)
   ```

2. **Eventos fallidos:**
   ```ruby
   LoyverseWebhookEvent.failed.recent.each do |event|
     puts "#{event.event_type}: #{event.error_message}"
   end
   ```

3. **Latencia de procesamiento:**
   ```ruby
   LoyverseWebhookEvent.processed.each do |event|
     latency = event.processed_at - event.created_at
     puts "#{event.event_type}: #{latency}s"
   end
   ```

### Alertas recomendadas

- ⚠️ Más de 10 webhooks fallidos en última hora
- ⚠️ Webhook no recibido en últimas 2 horas (durante horario de operación)
- ⚠️ Latencia de procesamiento > 30 segundos

---

## Seguridad

### Validación de firma (opcional)

Loyverse envía `X-Loyverse-Webhook-Signature` para validar autenticidad:

```ruby
# En LoyverseConfig
def verify_webhook_signature(payload, signature)
  expected = OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload)
  ActiveSupport::SecurityUtils.secure_compare(expected, signature)
end
```

**Nota:** Actualmente no implementado, pero el campo `signature` se guarda para uso futuro.

---

## Recursos

- [Documentación Loyverse Webhooks](https://developer.loyverse.com/docs#tag/Webhooks)
- [ngrok Documentation](https://ngrok.com/docs)
- Código fuente: `app/controllers/api/v1/loyverse/webhooks_controller.rb`
- Modelo: `app/models/loyverse_webhook_event.rb`

---

**Última actualización:** 2025-11-18
