# Sistema de Validación de Cierre de Caja

Esta guía explica cómo funciona el **sistema de validación automática** que detecta discrepancias entre los datos reportados manualmente y los datos reales de Loyverse POS.

---

## 📋 Índice

- [¿Qué Problemas Resuelve?](#qué-problemas-resuelve)
- [Cómo Funciona](#cómo-funciona)
- [Tipos de Validación](#tipos-de-validación)
- [Niveles de Severidad](#niveles-de-severidad)
- [API Endpoints](#api-endpoints)
- [Flujos de Uso](#flujos-de-uso)
- [Ejemplos de Respuestas](#ejemplos-de-respuestas)
- [Configuración](#configuración)

---

## ¿Qué Problemas Resuelve?

### 1. **Faltantes de Efectivo**
Detecta cuando reportas **menos dinero** del que realmente vendiste.

**Ejemplo:**
```
Ventas en efectivo (Loyverse): $2,500
Efectivo reportado (Tu reporte): $2,200
❌ FALTANTE: $300
```

### 2. **Errores de Captura**
Detecta cuando los números no coinciden por error humano.

**Ejemplo:**
```
Total ventas (Loyverse): $4,235.50
Total reportado: $4,325.50
⚠️ DISCREPANCIA: $90 (posible error de captura)
```

### 3. **Fraude o Intentos de Ocultar Ingresos**
Detecta patrones sospechosos en los datos.

**Ejemplo:**
```
Ventas totales: $3,500
Todos los métodos de pago: $0
❌ SOSPECHOSO: Datos inconsistentes
```

### 4. **Totales Internos Inconsistentes**
Verifica que la suma de métodos de pago coincida con el total.

**Ejemplo:**
```
Efectivo: $1,000
Tarjeta: $800
Transferencia: $500
Total reportado: $2,500
✅ CORRECTO: Suma coincide
```

---

## Cómo Funciona

### Flujo Automático (Webhook)

```
1. Empleado cierra turno en Loyverse
   ↓
2. Loyverse envía webhook shifts.create
   ↓
3. Sistema procesa shift y crea TurnClosure automáticamente
   ↓
4. ✅ NO REQUIERE VALIDACIÓN (datos vienen directo de Loyverse)
```

### Flujo Manual (Captura Manual)

```
1. Usuario ingresa datos manualmente en el frontend
   ↓
2. Frontend llama a POST /turn_closures/preview_validation
   ↓
3. Sistema compara con datos de Loyverse
   ↓
4. Retorna errores/warnings ANTES de crear
   ↓
5. Frontend muestra alertas al usuario
   ↓
6. Usuario decide: corregir datos o crear con warnings
   ↓
7. POST /turn_closures (con o sin skip_validation)
```

---

## Tipos de Validación

### 1. **Validación Interna**
Verifica que los datos ingresados sean consistentes entre sí.

```ruby
# Ejemplo:
cash_collected = 1000
card_income_gross = 800
transfer_income_gross = 500
total_income = 2300  # ✅ Correcto (1000 + 800 + 500)
total_income = 2500  # ❌ Error (no coincide con suma)
```

**Error bloqueante:** Sí (no permite crear el TurnClosure)

### 2. **Validación de Totales**
Compara el total reportado con el total de Loyverse.

```ruby
# Loyverse dice:
gross_sales = 4250.50

# Usuario reporta:
total_income = 4000.00  # ⚠️ WARNING: $250.50 menos

# Usuario reporta:
total_income = 4250.50  # ✅ CORRECTO
```

**Error bloqueante:** Solo si diferencia > 10% (crítico)

### 3. **Validación por Método de Pago**
Compara cada método de pago contra Loyverse.

```ruby
# Loyverse dice:
Efectivo (CASH): $1,500
Tarjeta (CARD): $2,300.50
Transferencia (CUSTOM): $450

# Usuario reporta:
cash_collected = 1,200  # ❌ ERROR CRÍTICO: Faltante de $300
card_income_gross = 2,300.50  # ✅ CORRECTO
transfer_income_gross = 450  # ✅ CORRECTO
```

**Error bloqueante:** Sí para faltantes de efectivo > $5

### 4. **Validación de Cuadre de Efectivo**
Verifica el cuadre de efectivo de Loyverse.

```ruby
# Loyverse shift dice:
expected_cash = 1,500  # Lo que DEBERÍA haber
actual_cash = 1,470    # Lo que REALMENTE hay

# Sistema alerta:
⚠️ FALTANTE de $30 en cuadre de Loyverse
```

**Error bloqueante:** No (solo warning)

### 5. **Detección de Patrones Sospechosos**
Identifica comportamientos anómalos.

#### a) Todos los pagos son cero
```ruby
cash_collected = 0
card_income_gross = 0
transfer_income_gross = 0
# ❌ CRÍTICO: Posible error de captura
```

#### b) Diferencia muy grande (>10%)
```ruby
loyverse_sales = 5000
reported_sales = 3000  # 40% menos
# ❌ CRÍTICO: Diferencia sospechosa
```

#### c) Efectivo = 0 pero hubo ventas en efectivo
```ruby
loyverse_cash = 1500
reported_cash = 0
# ⚠️ WARNING: Verifica si hubo ventas en efectivo
```

---

## Niveles de Severidad

### 🔴 `critical` - Error Crítico
- **Bloquea la creación** del TurnClosure
- Requiere corrección obligatoria
- Ejemplos:
  - Faltante de efectivo > $5
  - Diferencia total > 10%
  - Todos los pagos = $0
  - Total no coincide con suma de pagos

### ⚠️ `warning` - Advertencia
- **Permite crear** el TurnClosure
- Se guarda el warning en `validation_data`
- Requiere revisión recomendada
- Ejemplos:
  - Pequeñas diferencias en tarjetas
  - Sobrante de efectivo
  - Cuadre de Loyverse con diferencias menores

---

## API Endpoints

### 1. **Preview de Validación** (Recomendado)

Valida los datos **ANTES** de crear el TurnClosure.

```http
POST /api/v1/turn_closures/preview_validation
Content-Type: application/json

{
  "turn_closure": {
    "closure_date": "2025-11-17",
    "cash_collected": 1200,
    "card_income_gross": 2300.50,
    "transfer_income_gross": 450,
    "total_income": 3950.50
  }
}
```

**Respuesta cuando HAY ERRORES:**

```json
{
  "success": true,
  "can_create": false,
  "validation": {
    "valid": false,
    "has_warnings": false,
    "errors": [
      {
        "type": "cash_shortage",
        "field": "cash_collected",
        "message": "Efectivo reportado ($1200) es MENOR que ventas en efectivo ($1500)",
        "difference": 300,
        "severity": "critical",
        "recommendation": "Verificar faltante de efectivo en caja"
      }
    ],
    "warnings": [],
    "discrepancies": {
      "cash": {
        "expected": 1500,
        "reported": 1200,
        "difference": -300
      },
      "card": {
        "expected": 2300.50,
        "reported": 2300.50,
        "difference": 0
      },
      "transfer": {
        "expected": 450,
        "reported": 450,
        "difference": 0
      },
      "total": {
        "expected": 4250.50,
        "reported": 3950.50,
        "difference": -300,
        "percentage": -7.06
      }
    },
    "shift_data": {
      "shift_id": "shift-abc-123",
      "closed_at": "2025-11-17T22:30:00Z",
      "cash": 1500,
      "card": 2300.50,
      "transfer": 450,
      "total": 4250.50,
      "receipts_count": 25,
      "cash_balanced": false,
      "cash_difference": -30
    }
  },
  "recommendation": "HAY ERRORES CRÍTICOS. Verifica los montos antes de continuar."
}
```

**Respuesta cuando TODO ESTÁ CORRECTO:**

```json
{
  "success": true,
  "can_create": true,
  "validation": {
    "valid": true,
    "has_warnings": false,
    "errors": [],
    "warnings": [],
    "discrepancies": {
      "cash": { "expected": 1500, "reported": 1500, "difference": 0 },
      "card": { "expected": 2300.50, "reported": 2300.50, "difference": 0 },
      "transfer": { "expected": 450, "reported": 450, "difference": 0 },
      "total": { "expected": 4250.50, "reported": 4250.50, "difference": 0, "percentage": 0 }
    }
  },
  "recommendation": "Datos correctos. Puedes crear el cierre de caja."
}
```

### 2. **Crear TurnClosure con Validación**

```http
POST /api/v1/turn_closures
Content-Type: application/json

{
  "turn_closure": {
    "closure_number": "20251117-001",
    "closure_date": "2025-11-17",
    "cash_collected": 1200,
    "card_income_gross": 2300.50,
    "transfer_income_gross": 450,
    "total_income": 3950.50
  }
}
```

**Si hay errores críticos:**
```json
{
  "success": false,
  "errors": [
    "Efectivo reportado ($1200) es MENOR que ventas en efectivo ($1500)"
  ],
  "validation_errors": [...]
}
```

**Status:** `422 Unprocessable Entity`

### 3. **Crear TurnClosure SALTANDO Validación**

Si estás 100% seguro y quieres crear aunque haya discrepancias:

```http
POST /api/v1/turn_closures?skip_validation=true
Content-Type: application/json

{
  "turn_closure": {
    "closure_number": "20251117-001",
    "closure_date": "2025-11-17",
    "cash_collected": 1200,
    "card_income_gross": 2300.50,
    "transfer_income_gross": 450,
    "total_income": 3950.50,
    "notes": "Faltante de $300 confirmado - reportado a gerencia"
  }
}
```

**Status:** `201 Created`

**IMPORTANTE:** El cierre se crea, pero queda marcado con `has_warnings: true` o `has_errors: true` para auditoría.

### 4. **Validar TurnClosure Existente**

Si ya creaste un TurnClosure y quieres validarlo después:

```http
POST /api/v1/turn_closures/:id/validate_with_loyverse
```

**Respuesta:**

```json
{
  "success": true,
  "validation": {
    "valid": false,
    "has_warnings": true,
    "errors": [...],
    "warnings": [...]
  },
  "turn_closure": {
    "id": 123,
    "closure_number": "20251117-001",
    "validation_status": "warning",
    "has_errors": false,
    "has_warnings": true
  }
}
```

### 5. **Listar TurnClosures con Filtros**

```http
# Mostrar solo los que tienen errores
GET /api/v1/turn_closures?with_errors=true

# Mostrar solo los que tienen warnings
GET /api/v1/turn_closures?with_warnings=true

# Mostrar solo validados
GET /api/v1/turn_closures?validated=true

# Mostrar no validados
GET /api/v1/turn_closures?validated=false

# Filtrar por rango de fechas
GET /api/v1/turn_closures?start_date=2025-11-01&end_date=2025-11-17
```

---

## Flujos de Uso

### Flujo 1: Creación Manual con Validación (Recomendado)

```javascript
// 1. Usuario llena formulario en frontend
const formData = {
  closure_date: "2025-11-17",
  cash_collected: 1500,
  card_income_gross: 2300.50,
  transfer_income_gross: 450,
  total_income: 4250.50
};

// 2. Preview de validación ANTES de crear
const preview = await fetch('/api/v1/turn_closures/preview_validation', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ turn_closure: formData })
});

const result = await preview.json();

// 3. Mostrar errores/warnings al usuario
if (!result.can_create) {
  // ❌ Mostrar errores críticos
  alert('HAY ERRORES: ' + result.validation.errors.map(e => e.message).join('\n'));
  // NO PERMITIR CREAR
} else if (result.validation.has_warnings) {
  // ⚠️ Mostrar warnings
  const confirm = window.confirm(
    'HAY ADVERTENCIAS:\n' +
    result.validation.warnings.map(w => w.message).join('\n') +
    '\n\n¿Crear de todas formas?'
  );

  if (confirm) {
    // 4. Crear con warnings (usuario aceptó)
    await createTurnClosure(formData, skip_validation: true);
  }
} else {
  // ✅ Todo correcto, crear normalmente
  await createTurnClosure(formData);
}
```

### Flujo 2: Validación de TurnClosure Existente

```javascript
// Validar un cierre que ya existe
const validate = await fetch('/api/v1/turn_closures/123/validate_with_loyverse', {
  method: 'POST'
});

const result = await validate.json();

// Mostrar status en UI
if (result.turn_closure.validation_status === 'error') {
  showErrorBadge('ERRORES DETECTADOS');
} else if (result.turn_closure.validation_status === 'warning') {
  showWarningBadge('CON ADVERTENCIAS');
} else {
  showSuccessBadge('VALIDADO');
}
```

---

## Configuración

### Variables de Entorno

```bash
# Habilitar validación estricta (bloquea creación con errores)
LOYVERSE_STRICT_VALIDATION=true

# Deshabilitar validación estricta (solo warnings)
LOYVERSE_STRICT_VALIDATION=false
```

**Recomendación:** Usar `LOYVERSE_STRICT_VALIDATION=true` en producción para prevenir faltantes de efectivo.

### Umbrales de Tolerancia

Puedes modificar en `app/services/turn_closures/validator.rb`:

```ruby
# Tolerancia en pesos
TOLERANCE_AMOUNT = 5.0  # $5 pesos

# Tolerancia en porcentaje
TOLERANCE_PERCENTAGE = 0.5  # 0.5%
```

**Ejemplo:** Con `TOLERANCE_AMOUNT = 5.0`, una diferencia de $4 no genera error, pero $6 sí.

---

## Campos en Base de Datos

### Tabla: `turn_closures`

```sql
ALTER TABLE turn_closures ADD COLUMN validation_data JSONB DEFAULT '{}' NOT NULL;
ALTER TABLE turn_closures ADD COLUMN validated_at TIMESTAMP;
ALTER TABLE turn_closures ADD COLUMN has_errors BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE turn_closures ADD COLUMN has_warnings BOOLEAN DEFAULT FALSE NOT NULL;
```

### `validation_data` (JSONB)

Almacena el resultado completo de la validación:

```json
{
  "valid": false,
  "has_warnings": true,
  "errors": [...],
  "warnings": [...],
  "discrepancies": {...}
}
```

### `validation_status` (Computed)

- `"not_validated"` - Nunca validado
- `"valid"` - Validado sin errores ni warnings
- `"warning"` - Validado con warnings
- `"error"` - Validado con errores

---

## Auditoría y Reportes

### Consultar Cierres con Problemas

```ruby
# Todos los que tienen errores
TurnClosure.with_errors

# Todos los que tienen warnings
TurnClosure.with_warnings

# No validados
TurnClosure.unvalidated

# Validados exitosamente
TurnClosure.validated.where(has_errors: false, has_warnings: false)
```

### Calcular Faltantes Totales

```ruby
# Suma de todos los faltantes de efectivo
TurnClosure.with_errors.sum do |tc|
  tc.discrepancies.dig('cash', 'difference') || 0
end
```

---

## Mejores Prácticas

### ✅ DO

1. **Siempre usar `preview_validation` antes de crear** manualmente
2. **Revisar discrepancias** antes de decidir
3. **Agregar notas** cuando creas con `skip_validation=true`
4. **Monitorear cierres con warnings** regularmente
5. **Investigar faltantes de efectivo** inmediatamente

### ❌ DON'T

1. **NO saltar validación** sin justificación
2. **NO ignorar warnings** sistemáticamente
3. **NO modificar umbrales** sin análisis previo
4. **NO eliminar cierres** con errores sin investigar

---

## Soporte

Si encuentras un falso positivo o el sistema marca errores incorrectamente:

1. Verifica los datos en Loyverse POS
2. Confirma que el shift está cerrado
3. Revisa los receipts asociados: `GET /api/v1/loyverse/shifts/:id`
4. Reporta el issue con datos específicos

---

**Última actualización:** 17 de noviembre, 2025
**Versión:** 1.0.0
