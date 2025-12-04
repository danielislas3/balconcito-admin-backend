# Documentación de API - Balconcito Admin

Esta guía explica cómo acceder y usar la documentación interactiva de la API.

---

## 📚 Swagger UI (Recomendado)

### Acceso Rápido

Una vez que el servidor esté corriendo:

```bash
cd backend
bundle install
rails server
```

**Abre en tu navegador:**
```
http://localhost:3000/api-docs
```

### ¿Qué puedes hacer en Swagger UI?

1. **Ver todos los endpoints** organizados por categorías
2. **Probar requests** directamente desde el navegador (botón "Try it out")
3. **Ver ejemplos** de requests y responses
4. **Copiar curl commands** para usar en terminal
5. **Autenticarte** con tu token JWT

---

## 🔐 Autenticación en Swagger

### Paso 1: Obtener Token JWT

1. En Swagger UI, busca el endpoint `POST /api/v1/auth/login`
2. Click en "Try it out"
3. Ingresa credenciales:
   ```json
   {
     "email": "admin@balconcito.com",
     "password": "password123"
   }
   ```
4. Click en "Execute"
5. **Copia el token** del header `Authorization` en la respuesta

### Paso 2: Configurar Token

1. Click en el botón **"Authorize"** (arriba a la derecha, ícono de candado)
2. Pega el token completo (incluye "Bearer "):
   ```
   Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3MzIwNTg...
   ```
3. Click en "Authorize"
4. Click en "Close"

✅ **Ahora todos los endpoints protegidos funcionarán con ese token!**

---

## 🧪 Probando Endpoints

### Ejemplo: Crear Cierre de Caja

1. Busca `POST /api/v1/turn_closures/preview_validation`
2. Click en "Try it out"
3. Modifica el JSON de ejemplo:
   ```json
   {
     "turn_closure": {
       "closure_date": "2025-11-17",
       "cash_collected": 1500,
       "card_income_gross": 2300.50,
       "transfer_income_gross": 450,
       "total_income": 4250.50
     }
   }
   ```
4. Click en "Execute"
5. **Ver resultado** - te dirá si hay discrepancias con Loyverse

---

## 📥 Exportar a Postman

### Opción 1: Importar desde URL

1. Abre Postman
2. Click en "Import"
3. Selecciona "Link"
4. Pega la URL:
   ```
   http://localhost:3000/api-docs/v1/swagger.yaml
   ```
5. Click en "Continue" → "Import"

✅ **Postman creará automáticamente una colección con todos los endpoints!**

### Opción 2: Descargar Archivo

1. Descarga el archivo:
   ```bash
   curl http://localhost:3000/api-docs/v1/swagger.yaml > balconcito-api.yaml
   ```

2. En Postman:
   - Click en "Import"
   - Arrastra el archivo `balconcito-api.yaml`
   - Click en "Import"

---

## 📋 Endpoints Principales

### Autenticación
- `POST /api/v1/auth/login` - Login
- `DELETE /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Usuario actual

### Cierres de Caja (Turn Closures)
- `GET /api/v1/turn_closures` - Listar
- `POST /api/v1/turn_closures` - Crear
- `POST /api/v1/turn_closures/preview_validation` - **Validar ANTES de crear**
- `POST /api/v1/turn_closures/:id/validate_with_loyverse` - Validar existente
- `DELETE /api/v1/turn_closures/:id` - Eliminar

### Dashboard
- `GET /api/v1/dashboard/summary` - KPIs generales
- `GET /api/v1/dashboard/debt` - Resumen de deudas
- `GET /api/v1/dashboard/profitability` - Rentabilidad
- `GET /api/v1/dashboard/cash_flow` - Flujo de efectivo
- `GET /api/v1/dashboard/break_even` - Punto de equilibrio

### Loyverse
- `GET /api/v1/loyverse/shifts` - Lista de turnos
- `GET /api/v1/loyverse/receipts` - Lista de tickets
- `GET /api/v1/loyverse/config` - Configuración
- `PATCH /api/v1/loyverse/config` - Actualizar config
- `POST /api/v1/loyverse/receipts/sync` - Sincronizar manualmente

### Gastos
- `GET /api/v1/expenses` - Listar gastos
- `POST /api/v1/expenses` - Crear gasto
- `GET /api/v1/expenses/pending_reimbursement` - Pendientes de reembolso

### Deudas
- `GET /api/v1/credit_cards` - Tarjetas de crédito
- `POST /api/v1/credit_cards` - Agregar tarjeta
- `GET /api/v1/lenders` - Prestamistas
- `POST /api/v1/loans` - Registrar préstamo

---

## 🎯 Casos de Uso Comunes

### 1. Validar Cierre de Caja Manualmente

**Flujo recomendado:**

```bash
# 1. Preview (validar SIN crear)
POST /api/v1/turn_closures/preview_validation
{
  "turn_closure": {
    "closure_date": "2025-11-17",
    "cash_collected": 1200,
    "card_income_gross": 2300.50,
    "transfer_income_gross": 450,
    "total_income": 3950.50
  }
}

# Respuesta:
{
  "can_create": false,  # ← NO puede crear
  "validation": {
    "errors": [
      {
        "type": "cash_shortage",
        "message": "Efectivo reportado ($1200) es MENOR que ventas en efectivo ($1500)",
        "difference": 300
      }
    ]
  }
}

# 2. Si hay errores, CORREGIR datos:
POST /api/v1/turn_closures/preview_validation
{
  "turn_closure": {
    "cash_collected": 1500,  # ← Corregido
    ...
  }
}

# Respuesta:
{
  "can_create": true,  # ← Ahora SÍ
  "recommendation": "Datos correctos. Puedes crear el cierre de caja."
}

# 3. Crear el cierre
POST /api/v1/turn_closures
{
  "turn_closure": {
    "closure_number": "20251117-001",
    "closure_date": "2025-11-17",
    "cash_collected": 1500,
    "card_income_gross": 2300.50,
    "transfer_income_gross": 450,
    "total_income": 4250.50
  }
}
```

### 2. Ver Métricas del Día

```bash
GET /api/v1/dashboard/summary?start_date=2025-11-17&end_date=2025-11-17
```

### 3. Listar Cierres con Problemas

```bash
# Solo cierres con errores
GET /api/v1/turn_closures?with_errors=true

# Solo cierres con warnings
GET /api/v1/turn_closures?with_warnings=true
```

### 4. Ver Shifts de Loyverse No Convertidos

```bash
# Shifts que aún no tienen TurnClosure
GET /api/v1/loyverse/shifts?unconverted=true
```

---

## 🔍 Filtros Disponibles

### Turn Closures
- `start_date` y `end_date` - Rango de fechas
- `with_errors=true` - Solo con errores críticos
- `with_warnings=true` - Solo con warnings
- `validated=true` - Solo validados
- `validated=false` - No validados
- `page` y `per_page` - Paginación

### Loyverse Shifts
- `unconverted=true` - Sin TurnClosure asociado
- `converted=true` - Con TurnClosure asociado
- `start_date` y `end_date` - Rango de fechas

### Dashboard
- `start_date` y `end_date` - Rango de fechas para métricas

---

## 📊 Estructura de Respuestas

### Éxito (200/201)
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

### Error de Validación (422)
```json
{
  "success": false,
  "errors": [
    "Campo requerido no puede estar vacío",
    "Total no coincide con suma de pagos"
  ]
}
```

### Error de Autenticación (401)
```json
{
  "error": "Unauthorized",
  "message": "Token inválido o expirado"
}
```

### Paginación
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 10,
    "total_count": 245
  }
}
```

---

## 🛠️ Ejemplos con cURL

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@balconcito.com",
    "password": "password123"
  }'
```

### Crear Cierre (con token)
```bash
curl -X POST http://localhost:3000/api/v1/turn_closures \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -d '{
    "turn_closure": {
      "closure_number": "20251117-001",
      "closure_date": "2025-11-17",
      "cash_collected": 1500,
      "card_income_gross": 2300.50,
      "transfer_income_gross": 450,
      "total_income": 4250.50
    }
  }'
```

### Ver Dashboard
```bash
curl http://localhost:3000/api/v1/dashboard/summary \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

---

## 🎨 Personalizar Swagger

Si quieres agregar más endpoints o modificar la documentación:

1. Edita el archivo: `backend/swagger/v1/swagger.yaml`
2. Reinicia el servidor: `rails restart`
3. Recarga Swagger UI: http://localhost:3000/api-docs

---

## 🚀 Producción

En producción, la URL será:

```
https://api.balconcito.com/api-docs
```

**Importante:** Considera restringir el acceso a Swagger en producción si contiene información sensible.

---

## 📖 Documentación Adicional

- [Guía de Validación de Cierres](VALIDACION_TURN_CLOSURES.md)
- [Setup de Loyverse](LOYVERSE_SETUP.md)
- [Integración Completa](LOYVERSE_INTEGRATION.md)

---

## 💡 Tips

1. **Usa preview_validation** SIEMPRE antes de crear cierres manualmente
2. **Revisa warnings** - pueden indicar problemas reales
3. **Filtra por errores** para encontrar cierres problemáticos
4. **Exporta a Postman** si prefieres trabajar ahí
5. **Guarda tokens** en variables de entorno en Postman

---

## 🐛 Troubleshooting

### "Cannot GET /api-docs"

Asegúrate de que el servidor esté corriendo:
```bash
rails server
```

### "401 Unauthorized" en todos los endpoints

Tu token expiró. Haz login nuevamente:
```bash
POST /api/v1/auth/login
```

### Swagger UI no se ve bien

Limpia caché del navegador o prueba en ventana incógnita.

---

**Última actualización:** 17 de noviembre, 2025
**Versión API:** v1
