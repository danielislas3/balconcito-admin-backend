# Reset Completo de Base de Datos y Sincronización

Este documento describe cómo resetear completamente la base de datos y sincronizar Loyverse desde cero.

## Opción A: Script Automatizado (Recomendado)

```bash
cd backend
./scripts/reset_and_sync.sh
```

El script ejecuta todos los pasos automáticamente con pausas para revisar.

---

## Opción B: Pasos Manuales

### 1. Drop y recrear base de datos

```bash
cd backend

# Drop (eliminar completamente)
bin/rails db:drop

# Crear de nuevo
bin/rails db:create

# Ejecutar todas las migraciones
bin/rails db:migrate
```

**Resultado esperado:**
- Base de datos limpia
- Todas las tablas creadas
- Schema actualizado

---

### 2. Cargar Seeds (datos iniciales)

```bash
bin/rails db:seed
```

**Crea:**
- ✅ Usuarios (daniel@balconcito.com, raul@balconcito.com)
- ✅ Cuentas (Mercado Pago, Bóveda, etc.)
- ✅ Payment Methods (Efectivo, Tarjeta, Transferencia, etc.)
- ✅ Otros datos iniciales

**Verificar:**
```bash
bin/rails runner "
  puts 'Usuarios: ' + User.count.to_s
  puts 'Cuentas: ' + Account.count.to_s
  puts 'Payment Methods: ' + PaymentMethod.count.to_s
"
```

---

### 3. Verificar conexión con Loyverse

```bash
bin/rails loyverse:test_connection
```

**Debe mostrar:**
- ✅ Conexión exitosa
- Lista de tiendas
- Lista de payment types

**Si falla:**
- Verificar `LOYVERSE_API_TOKEN` en `.env`
- Verificar que el token sea válido

---

### 4. Sincronizar Payment Types

```bash
bin/rails loyverse:sync_payment_types
```

**Resultado:**
- Crea `LoyversePaymentMapping` para cada payment type de Loyverse
- Auto-mapea tipos conocidos (CASH→Efectivo, CARD→Tarjeta)

**Revisar mappings:**
```bash
bin/rails runner "
  LoyversePaymentMapping.all.each do |mapping|
    status = mapping.mapped? ? '✅' : '⚠️ '
    method = mapping.payment_method&.name || 'SIN MAPEAR'
    puts \"#{status} #{mapping.loyverse_payment_name} (#{mapping.loyverse_payment_type}) → #{method}\"
  end
"
```

**Mapear manualmente si es necesario:**

Via API (con JWT):
```bash
curl -X PATCH http://localhost:3000/api/v1/loyverse/payment_mappings/1 \
  -H "Authorization: Bearer YOUR_JWT" \
  -H "Content-Type: application/json" \
  -d '{"payment_method_id": 2}'
```

Via consola:
```bash
bin/rails console
> mapping = LoyversePaymentMapping.find(1)
> mapping.update!(payment_method_id: 2)
```

---

### 5. Sincronizar SHIFTS (Turnos de Caja)

**IMPORTANTE:** Esto sincroniza shifts (turnos), NO receipts individuales.

```bash
# Sincronizar últimos 3 meses
bin/rails loyverse:sync_shifts[2024-08-18,2025-11-18]

# O usar fechas dinámicas
START_DATE=$(date -d "3 months ago" +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)
bin/rails loyverse:sync_shifts[$START_DATE,$END_DATE]
```

**Esto hace:**
1. Obtiene todos los shifts del período
2. Para cada shift:
   - Obtiene datos del shift (empleado, horario, totales)
   - Obtiene todos los receipts del shift
   - Calcula totales por payment type
   - Crea **UN TurnClosure por shift**

**Monitorear progreso:**
```bash
# En otra terminal
tail -f log/development.log | grep -E "(Shift|TurnClosure)"
```

**Verificar resultados:**
```bash
bin/rails runner "
  puts 'Shifts sincronizados: ' + LoyverseShift.count.to_s
  puts 'Receipts sincronizados: ' + LoyverseReceipt.count.to_s
  puts 'TurnClosures creados: ' + TurnClosure.count.to_s
"
```

---

### 6. (Opcional) Sincronizar solo Receipts

Si por alguna razón necesitas sincronizar receipts sin crear TurnClosures:

```bash
bin/rails loyverse:sync_receipts_only[2025-11-01,2025-11-18]
```

**Nota:** Normalmente NO necesitas esto. Los receipts se sincronizan automáticamente al procesar shifts.

---

## Verificación Final

### Resumen completo

```bash
bin/rails runner "
puts '═══════════════════════════════════════════════════'
puts 'RESUMEN DE LA BASE DE DATOS'
puts '═══════════════════════════════════════════════════'
puts ''

puts '👥 USUARIOS:'
User.all.each { |u| puts \"  • #{u.name} (#{u.email})\" }

puts ''
puts '🏦 CUENTAS:'
Account.all.each { |a| puts \"  • #{a.name} ($#{a.current_balance})\" }

puts ''
puts '💳 PAYMENT METHODS:'
PaymentMethod.all.each { |pm| puts \"  • #{pm.name} (#{pm.payment_type})\" }

puts ''
puts '🔗 LOYVERSE PAYMENT MAPPINGS:'
total = LoyversePaymentMapping.count
mapped = LoyversePaymentMapping.mapped.count
puts \"  Total: #{total}\"
puts \"  Mapeados: #{mapped}\"
puts \"  Sin mapear: #{total - mapped}\"

puts ''
puts '📊 DATOS DE LOYVERSE:'
puts \"  Shifts: #{LoyverseShift.count}\"
puts \"  Receipts: #{LoyverseReceipt.count}\"
puts \"  TurnClosures: #{TurnClosure.count}\"

puts ''
puts '💰 ÚLTIMOS TURNCLOSURES:'
TurnClosure.order(closure_date: :desc).limit(5).each do |tc|
  shift = tc.loyverse_shift
  shift_info = shift ? \" [Shift: #{shift.loyverse_id}]\" : ' [Manual]'
  puts \"  • #{tc.closure_number} - #{tc.closure_date} - $#{tc.total_income}#{shift_info}\"
end

puts ''
puts '═══════════════════════════════════════════════════'
"
```

---

### Verificar integridad

```bash
# Verificar que todos los TurnClosures tienen validation_data
bin/rails runner "
  invalid = TurnClosure.where(validation_data: nil)
  if invalid.any?
    puts '❌ TurnClosures con validation_data null: ' + invalid.count.to_s
  else
    puts '✅ Todos los TurnClosures tienen validation_data correcto'
  end
"

# Verificar que los shifts están asociados correctamente
bin/rails runner "
  shifts_with_closure = LoyverseShift.where.not(turn_closure_id: nil).count
  total_shifts = LoyverseShift.count
  puts \"Shifts con TurnClosure: #{shifts_with_closure}/#{total_shifts}\"
"

# Verificar receipts asociados a shifts
bin/rails runner "
  receipts_with_shift = LoyverseReceipt.where.not(loyverse_shift_id: nil).count
  total_receipts = LoyverseReceipt.count
  puts \"Receipts asociados a shift: #{receipts_with_shift}/#{total_receipts}\"
"
```

---

## Troubleshooting

### Error: "connection refused"

PostgreSQL no está corriendo:

```bash
# Con Docker
docker-compose up -d postgres

# O verificar status
docker-compose ps
```

---

### Error: "Invalid API token"

Token de Loyverse inválido o expirado:

1. Verificar `.env`:
   ```bash
   cat .env | grep LOYVERSE
   ```

2. Obtener nuevo token desde Loyverse Dashboard

3. Actualizar `.env`:
   ```bash
   LOYVERSE_API_TOKEN=tu_nuevo_token
   ```

4. Reiniciar Rails (si está corriendo)

---

### Error: "Resource not found" al sincronizar shifts

La API de Loyverse puede no soportar `GET /shifts` con filtros.

**Solución:**
Usar webhooks para recibir shifts en tiempo real (ver `docs/LOYVERSE_WEBHOOKS.md`)

---

### Sincronización muy lenta

**Normal:**
- Loyverse tiene rate limit de 60 requests/minuto
- El código hace pausa automática cada 50 requests

**Optimizar:**
- Sincronizar períodos más cortos
- Usar webhooks para sincronización en tiempo real

---

### Payment types sin mapear

Algunos payment types de Loyverse no se mapean automáticamente.

**Solución:**

1. Ver payment types sin mapear:
   ```bash
   bin/rails runner "
     LoyversePaymentMapping.unmapped.each do |m|
       puts \"ID: #{m.id} - #{m.loyverse_payment_name} (#{m.loyverse_payment_type})\"
     end
   "
   ```

2. Ver payment methods disponibles:
   ```bash
   bin/rails runner "
     PaymentMethod.all.each { |pm| puts \"ID: #{pm.id} - #{pm.name}\" }
   "
   ```

3. Mapear manualmente:
   ```bash
   bin/rails runner "
     mapping = LoyversePaymentMapping.find(MAPPING_ID)
     mapping.update!(payment_method_id: PAYMENT_METHOD_ID)
   "
   ```

---

## Atajos Útiles

### Reset rápido (solo DB, sin sincronizar)

```bash
bin/rails db:reset  # = drop + create + migrate + seed
```

### Ver últimos logs de sincronización

```bash
tail -n 100 log/development.log | grep -E "(Loyverse|Shift|Receipt|TurnClosure)"
```

### Borrar solo datos de Loyverse

```bash
bin/rails runner "
  TurnClosure.where(closed_by: 'Loyverse').destroy_all
  LoyverseReceipt.destroy_all
  LoyverseShift.destroy_all
  LoyversePaymentMapping.destroy_all
  puts '✅ Datos de Loyverse eliminados'
"
```

---

## Próximos Pasos

Después del reset completo:

1. ✅ **Configurar webhooks** (para sincronización en tiempo real)
   - Ver: `docs/LOYVERSE_WEBHOOKS.md`

2. ✅ **Mapear payment types faltantes**
   - Via API: `PATCH /api/v1/loyverse/payment_mappings/:id`

3. ✅ **Verificar TurnClosures**
   - Revisar totales
   - Verificar cálculos de payment types

4. ✅ **Desarrollar frontend**
   - Dashboard de TurnClosures
   - Gestión de payment mappings
   - Visualización de shifts

---

**Última actualización:** 2025-11-18
