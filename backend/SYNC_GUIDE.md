# 🔄 Guía de Sincronización con Loyverse

Esta guía explica cómo usar los scripts de sincronización con Loyverse (Milestone 4).

## 📋 Estado Actual

⚠️ **IMPORTANTE:** La integración completa con Loyverse API está planificada para el **Milestone 4**.

Actualmente los scripts están creados pero retornan mensajes informativos. La funcionalidad completa se implementará cuando se agregue:
- Servicio `LoyverseService`
- Configuración de API token
- Mapeo de datos Loyverse → Balconcito ERP

## 🚀 Comandos Disponibles

### Opción 1: Script interactivo (recomendado)

```bash
cd backend
bin/sync
```

Esto abrirá un menú interactivo con todas las opciones disponibles.

### Opción 2: Comandos directos

#### 1. Sincronizar payment types
```bash
bin/rails loyverse:sync_payment_types
```

Sincroniza los métodos de pago desde Loyverse.

#### 2. Sincronizar receipts (rango de fechas)
```bash
# Sintaxis: bin/rails loyverse:sync_receipts[FECHA_INICIO,FECHA_FIN]

# Ejemplo: Sincronizar del 1 al 18 de noviembre
bin/rails loyverse:sync_receipts[2024-11-01,2024-11-18]

# Sin argumentos: usa el mes actual
bin/rails loyverse:sync_receipts
```

Importa los cierres de caja (receipts) de Loyverse y los convierte en `TurnClosure` en Balconcito ERP.

#### 3. Sincronización completa
```bash
bin/rails loyverse:full_sync
```

Ejecuta:
1. Sincronización de payment types
2. Sincronización de receipts del mes actual

#### 4. Verificar configuración
```bash
bin/rails loyverse:check_config
```

Verifica que el `LOYVERSE_API_TOKEN` esté configurado correctamente.

#### 5. Ver estadísticas
```bash
bin/rails loyverse:stats
```

Muestra estadísticas de los datos actuales en el sistema:
- Cierres de turno (hoy, esta semana, este mes)
- Gastos (hoy, esta semana, este mes)
- Métodos de pago activos
- Reembolsos pendientes

## ⚙️ Configuración

### 1. Obtener API Token de Loyverse

1. Inicia sesión en Loyverse: https://r.loyverse.com
2. Ve a **Settings → API Access**
3. Genera un nuevo token
4. Copia el token

### 2. Configurar en el proyecto

Crea un archivo `.env` en la carpeta `backend/`:

```bash
# backend/.env
LOYVERSE_API_TOKEN=tu_token_aqui
```

O exporta la variable de entorno:

```bash
export LOYVERSE_API_TOKEN=tu_token_aqui
```

### 3. Verificar configuración

```bash
bin/rails loyverse:check_config
```

Deberías ver:
```
✅ LOYVERSE_API_TOKEN configurado
   Token: abcd1234...
```

## 🔧 Implementación Futura (Milestone 4)

Cuando se implemente la integración completa, estos scripts harán:

### `sync_payment_types`
- Obtener métodos de pago de Loyverse API
- Mapear a `PaymentMethod` en Balconcito
- Actualizar o crear registros según corresponda

### `sync_receipts`
- Obtener receipts (cierres de caja) de Loyverse API en el rango de fechas
- Por cada receipt:
  - Extraer datos: closure_number, report_date, cash, transfers, cards
  - Crear o actualizar `TurnClosure`
  - Actualizar saldos de cuentas automáticamente
- Detectar y reportar discrepancias

### `full_sync`
- Sincronización completa periódica (ideal para ejecutar diariamente)
- Puede configurarse en cron job

## 📊 Ejemplo de Flujo Completo

```bash
# 1. Verificar configuración
bin/rails loyverse:check_config

# 2. Ver estado actual
bin/rails loyverse:stats

# 3. Sincronizar payment types
bin/rails loyverse:sync_payment_types

# 4. Sincronizar cierres del mes
bin/rails loyverse:sync_receipts[2024-11-01,2024-11-30]

# 5. Ver nuevas estadísticas
bin/rails loyverse:stats
```

## 🤖 Automatización (Futuro)

### Cron Job Diario

Agrega a tu crontab para sincronización automática diaria:

```bash
# Ejecutar a las 2 AM todos los días
0 2 * * * cd /path/to/balconcito-admin/backend && bin/rails loyverse:full_sync >> log/loyverse_sync.log 2>&1
```

### Webhook (Opcional)

Loyverse soporta webhooks para sincronización en tiempo real. Esto se puede implementar en fases posteriores.

## 🐛 Troubleshooting

### Error: "LOYVERSE_API_TOKEN no configurado"
**Solución:** Asegúrate de tener el token en `.env` o exportado como variable de entorno.

### Error: "No se pudieron obtener receipts"
**Solución:**
1. Verifica que el token sea válido
2. Verifica que el rango de fechas sea correcto
3. Verifica conexión a internet

### Datos no coinciden con Loyverse
**Solución:**
1. Ejecuta `bin/rails loyverse:full_sync` para resincronizar
2. Verifica que no haya modificaciones manuales conflictivas

## 📚 Recursos

- [Loyverse API Docs](https://developer.loyverse.com/docs/)
- [Loyverse API - Receipts](https://developer.loyverse.com/docs/#tag/Receipts)
- [Balconcito ERP Spec](../BALCONCITO_ERP_SPEC.md) - Ver sección Milestone 4

## 🎯 Roadmap de Integración

- [x] Crear scripts Rake básicos
- [x] Crear script interactivo `bin/sync`
- [ ] Implementar `LoyverseService`
- [ ] Implementar sincronización de payment types
- [ ] Implementar sincronización de receipts
- [ ] Agregar validaciones y manejo de errores
- [ ] Agregar tests
- [ ] Configurar webhooks (opcional)
- [ ] Configurar cron jobs (opcional)

---

**Versión:** 1.0
**Última actualización:** Noviembre 19, 2024
**Milestone:** 4 (Integración Loyverse)
