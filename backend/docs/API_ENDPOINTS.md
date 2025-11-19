# API Endpoints - Balconcito Admin

Base URL: `http://localhost:3000/api/v1`

**Autenticación:** Todos los endpoints (excepto `/auth/login` y webhooks) requieren header:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📑 Tabla de Contenidos

- [Autenticación](#autenticación)
- [Cuentas (Accounts)](#cuentas-accounts)
- [Cierres de Turno (Turn Closures)](#cierres-de-turno-turn-closures)
- [Gastos (Expenses)](#gastos-expenses)
- [Métodos de Pago (Payment Methods)](#métodos-de-pago-payment-methods)
- [Reembolsos (Reimbursements)](#reembolsos-reimbursements)
- [Tarjetas de Crédito](#tarjetas-de-crédito)
- [Compras a Crédito](#compras-a-crédito)
- [Prestamistas (Lenders)](#prestamistas-lenders)
- [Préstamos (Loans)](#préstamos-loans)
- [Dashboard](#dashboard)
- [Loyverse Integration](#loyverse-integration)

---

## Autenticación

### POST /auth/login
Iniciar sesión y obtener JWT token

**Body:**
```json
{
  "email": "daniel@balconcito.com",
  "password": "password123"
}
```

**Response:**
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

### DELETE /auth/logout
Cerrar sesión (invalidar token)

### GET /auth/me
Obtener información del usuario actual

**Response:**
```json
{
  "id": 1,
  "email": "daniel@balconcito.com",
  "name": "Daniel",
  "role": "admin"
}
```

---

## Cuentas (Accounts)

### GET /accounts
Listar todas las cuentas

**Response:**
```json
[
  {
    "id": 1,
    "name": "Mercado Pago",
    "account_type": "digital",
    "current_balance": 15000.50,
    "description": "Cuenta digital..."
  }
]
```

### GET /accounts/:id
Ver detalle de una cuenta

### PATCH /accounts/:id
Actualizar cuenta

**Body:**
```json
{
  "current_balance": 20000.00,
  "description": "Nueva descripción"
}
```

---

## Cierres de Turno (Turn Closures)

### GET /turn_closures
Listar todos los cierres de turno

**Query params:**
- `start_date` (opcional): Filtrar desde fecha
- `end_date` (opcional): Filtrar hasta fecha
- `page` (opcional): Página
- `per_page` (opcional): Items por página

**Response:**
```json
{
  "turn_closures": [
    {
      "id": 1,
      "closure_number": "20251118-001",
      "closure_date": "2025-11-18",
      "closed_by": "Daniel",
      "cash_collected": 5000.00,
      "card_income_gross": 3000.00,
      "transfer_income_gross": 2000.00,
      "total_income": 10000.00,
      "theoretical_cash": 5000.00,
      "payments_withdrawals": 500.00,
      "has_errors": false,
      "has_warnings": false,
      "validated_at": "2025-11-18T10:00:00Z",
      "notes": "Cierre normal",
      "user_id": 1,
      "loyverse_shift_id": null
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100
  }
}
```

### POST /turn_closures
Crear un nuevo cierre de turno

**Body:**
```json
{
  "closure_number": "20251118-002",
  "closure_date": "2025-11-18",
  "closed_by": "Daniel",
  "cash_collected": 5000.00,
  "card_income_gross": 3000.00,
  "transfer_income_gross": 2000.00,
  "total_income": 10000.00,
  "theoretical_cash": 5000.00,
  "payments_withdrawals": 500.00,
  "notes": "Cierre de turno matutino"
}
```

### GET /turn_closures/:id
Ver detalle de un cierre

### PATCH /turn_closures/:id
Actualizar cierre

### DELETE /turn_closures/:id
Eliminar cierre

### POST /turn_closures/:id/validate_with_loyverse
Validar cierre contra datos de Loyverse

**Response:**
```json
{
  "valid": true,
  "has_warnings": false,
  "errors": [],
  "warnings": [],
  "discrepancies": {},
  "validated_at": "2025-11-18T10:00:00Z"
}
```

### POST /turn_closures/preview_validation
Vista previa de validación antes de crear

**Body:**
```json
{
  "closure_date": "2025-11-18",
  "cash_collected": 5000.00,
  "card_income_gross": 3000.00,
  "transfer_income_gross": 2000.00
}
```

---

## Gastos (Expenses)

### GET /expenses
Listar gastos

**Query params:**
- `start_date`, `end_date`: Filtrar por fecha
- `category`: Filtrar por categoría
- `requires_reimbursement`: `true`/`false`
- `reimbursed`: `true`/`false`

**Response:**
```json
[
  {
    "id": 1,
    "description": "Compra de ingredientes",
    "amount": 1500.00,
    "expense_date": "2025-11-18",
    "category": "supplies",
    "provider": "Proveedor XYZ",
    "payment_method_id": 1,
    "payment_method": {
      "id": 1,
      "name": "Tarjeta Personal Daniel"
    },
    "requires_reimbursement": true,
    "reimbursed": false,
    "receipt_photo_url": null,
    "user_id": 1
  }
]
```

### POST /expenses
Crear gasto

### GET /expenses/:id
Ver detalle

### PATCH /expenses/:id
Actualizar gasto

### DELETE /expenses/:id
Eliminar gasto

### GET /expenses/pending_reimbursement
Listar gastos pendientes de reembolso

---

## Métodos de Pago (Payment Methods)

### GET /payment_methods
Listar métodos de pago

**Response:**
```json
[
  {
    "id": 1,
    "name": "Caja Chica",
    "payment_type": "business_cash",
    "requires_reimbursement": false,
    "is_active": true,
    "description": "Efectivo en caja chica",
    "user_id": 1
  }
]
```

### POST /payment_methods
Crear método de pago

**Body:**
```json
{
  "name": "Nueva Tarjeta",
  "payment_type": "personal_card",
  "requires_reimbursement": true,
  "description": "Tarjeta personal"
}
```

### GET /payment_methods/:id
Ver detalle

### PATCH /payment_methods/:id
Actualizar

### DELETE /payment_methods/:id
Eliminar

---

## Reembolsos (Reimbursements)

### GET /reimbursements
Listar reembolsos

**Response:**
```json
[
  {
    "id": 1,
    "reimbursement_date": "2025-11-18",
    "total_amount": 5000.00,
    "paid": false,
    "payment_date": null,
    "notes": "Reembolso mensual",
    "user_id": 1,
    "expenses": [...]
  }
]
```

### POST /reimbursements
Crear reembolso

**Body:**
```json
{
  "reimbursement_date": "2025-11-18",
  "expense_ids": [1, 2, 3],
  "notes": "Reembolso semanal"
}
```

### GET /reimbursements/:id
Ver detalle con lista de gastos

---

## Tarjetas de Crédito

### GET /credit_cards
Listar tarjetas

**Response:**
```json
[
  {
    "id": 1,
    "name": "BBVA Oro",
    "bank_name": "BBVA",
    "credit_limit": 50000.00,
    "cut_day": 15,
    "statement_day": 20,
    "is_active": true,
    "notes": "",
    "user_id": 1
  }
]
```

### POST /credit_cards
Crear tarjeta

### GET /credit_cards/:id
Ver detalle

### PATCH /credit_cards/:id
Actualizar

### DELETE /credit_cards/:id
Eliminar

### GET /credit_cards/summary
Resumen de todas las tarjetas

**Response:**
```json
{
  "total_cards": 3,
  "active_cards": 2,
  "total_credit_limit": 150000.00,
  "total_debt": 45000.00,
  "available_credit": 105000.00
}
```

---

## Compras a Crédito

### GET /credit_purchases
Listar compras a crédito

**Query params:**
- `credit_card_id`: Filtrar por tarjeta
- `fully_paid`: `true`/`false`

**Response:**
```json
[
  {
    "id": 1,
    "concept": "Laptop",
    "total_amount": 20000.00,
    "monthly_payment": 2000.00,
    "total_months": 10,
    "paid_months": 3,
    "remaining_balance": 14000.00,
    "fully_paid": false,
    "purchase_date": "2025-09-01",
    "credit_card_id": 1,
    "user_id": 1
  }
]
```

### POST /credit_purchases
Crear compra a crédito

**Body:**
```json
{
  "concept": "Equipo de cocina",
  "total_amount": 15000.00,
  "total_months": 6,
  "purchase_date": "2025-11-18",
  "credit_card_id": 1
}
```

### GET /credit_purchases/:id
Ver detalle

### PATCH /credit_purchases/:id
Actualizar

### DELETE /credit_purchases/:id
Eliminar

### POST /credit_purchases/:id/record_payment
Registrar un pago

**Body:**
```json
{
  "amount": 2000.00,
  "payment_date": "2025-11-18",
  "notes": "Pago mensual"
}
```

### POST /credit_purchases/:id/mark_as_paid
Marcar como pagado completamente

### GET /credit_purchases/summary
Resumen de compras a crédito

---

## Prestamistas (Lenders)

### GET /lenders
Listar prestamistas

### POST /lenders
Crear prestamista

**Body:**
```json
{
  "name": "Juan Pérez",
  "phone": "555-1234",
  "email": "juan@example.com",
  "notes": "Prestamista confiable"
}
```

### GET /lenders/:id
Ver detalle

### PATCH /lenders/:id
Actualizar

### DELETE /lenders/:id
Eliminar

### GET /lenders/summary
Resumen de prestamistas

---

## Préstamos (Loans)

### GET /loans
Listar préstamos

### POST /loans
Crear préstamo

**Body:**
```json
{
  "concept": "Préstamo para capital de trabajo",
  "total_amount": 100000.00,
  "monthly_payment": 10000.00,
  "total_months": 10,
  "interest_rate": 12.5,
  "loan_date": "2025-11-01",
  "lender_id": 1
}
```

### GET /loans/:id
Ver detalle

### PATCH /loans/:id
Actualizar

### DELETE /loans/:id
Eliminar

### POST /loans/:id/record_payment
Registrar pago

### POST /loans/:id/mark_as_paid
Marcar como pagado

### GET /loans/summary
Resumen de préstamos

---

## Dashboard

### GET /dashboard/summary
Resumen general del negocio

**Response:**
```json
{
  "total_income": 50000.00,
  "total_expenses": 30000.00,
  "net_profit": 20000.00,
  "cash_balance": 10000.00,
  "pending_reimbursements": 5000.00,
  "active_loans": 3,
  "total_debt": 45000.00
}
```

### GET /dashboard/profitability
Análisis de rentabilidad

**Query params:**
- `start_date`, `end_date`: Rango de fechas
- `granularity`: `daily`, `weekly`, `monthly`

### GET /dashboard/break_even
Punto de equilibrio

### GET /dashboard/cash_flow
Flujo de efectivo

### GET /dashboard/expense_breakdown
Desglose de gastos por categoría

### GET /dashboard/debt
Resumen de deudas (tarjetas + préstamos)

---

## Loyverse Integration

### 🔧 Configuración

#### GET /loyverse/config
Obtener configuración actual

**Response:**
```json
{
  "config": {
    "id": 1,
    "api_token_present": true,
    "api_token_preview": "sk_l****1234",
    "webhook_secret_present": false,
    "last_sync_at": "2025-11-18T10:00:00Z",
    "sync_enabled": true,
    "configured": true,
    "sync_active": true
  }
}
```

#### PATCH /loyverse/config
Actualizar configuración

**Body:**
```json
{
  "api_token": "sk_live_xxxxxxxx",
  "sync_enabled": true
}
```

---

### 📋 Receipts (Tickets de Venta)

#### GET /loyverse/receipts
Listar receipts sincronizados

**Query params:**
- `start_date`, `end_date`: Filtrar por fecha
- `converted`: `true`/`false` (si ya se convirtió a TurnClosure)

**Response:**
```json
{
  "receipts": [
    {
      "id": 1,
      "loyverse_id": "2-0001",
      "receipt_number": "2-0001",
      "receipt_type": "SALE",
      "total_money": 500.00,
      "total_tax": 50.00,
      "loyverse_created_at": "2025-11-18T09:00:00Z",
      "synced_at": "2025-11-18T10:00:00Z",
      "converted": false,
      "loyverse_shift_id": null,
      "turn_closure_id": null
    }
  ]
}
```

#### GET /loyverse/receipts/:id
Ver detalle de un receipt (incluye items, pagos, etc.)

#### POST /loyverse/receipts/sync
Sincronizar receipts manualmente

**Body:**
```json
{
  "start_date": "2025-11-01",
  "end_date": "2025-11-18"
}
```

---

### 🔄 Shifts (Turnos de Caja)

#### GET /loyverse/shifts
Listar shifts sincronizados

**Response:**
```json
{
  "shifts": [
    {
      "id": 1,
      "loyverse_id": "shift_123",
      "store_id": "store_456",
      "opened_at": "2025-11-18T08:00:00Z",
      "closed_at": "2025-11-18T16:00:00Z",
      "opened_by_employee": "Juan",
      "closed_by_employee": "Juan",
      "starting_cash": 1000.00,
      "cash_payments": 5000.00,
      "expected_cash": 6000.00,
      "actual_cash": 5950.00,
      "gross_sales": 10000.00,
      "receipts_count": 45,
      "turn_closure_id": 123,
      "converted": true
    }
  ]
}
```

#### GET /loyverse/shifts/:id
Ver detalle de un shift (incluye receipts asociados)

---

### 💳 Payment Mappings

#### GET /loyverse/payment_mappings
Listar mapeos de payment types

**Response:**
```json
{
  "mappings": [
    {
      "id": 1,
      "loyverse_payment_type_id": "c499cac9-...",
      "loyverse_payment_type": "CASH",
      "loyverse_payment_name": "Efectivo",
      "payment_method_id": 2,
      "payment_method": {
        "id": 2,
        "name": "Bóveda",
        "payment_type": "business_cash"
      },
      "is_mapped": true
    }
  ],
  "summary": {
    "total_mappings": 3,
    "mapped_count": 3,
    "unmapped_count": 0
  }
}
```

#### PATCH /loyverse/payment_mappings/:id
Actualizar mapeo

**Body:**
```json
{
  "payment_method_id": 5
}
```

#### POST /loyverse/payment_mappings/sync
Sincronizar payment types de Loyverse

---

### 🔔 Webhooks

#### POST /loyverse/webhooks
Recibir webhooks de Loyverse (público, sin auth)

**Body ejemplo:**
```json
{
  "event_id": "evt_123",
  "event_type": "SHIFT_CREATED",
  "resource_type": "shift",
  "resource_id": "shift_456"
}
```

#### GET /loyverse/webhooks
Listar eventos webhook recibidos

#### POST /loyverse/webhooks/:id/retry
Reintentar procesamiento de webhook fallido

---

## Códigos de Estado HTTP

- `200 OK`: Éxito
- `201 Created`: Recurso creado
- `400 Bad Request`: Datos inválidos
- `401 Unauthorized`: No autenticado o token inválido
- `403 Forbidden`: Sin permisos
- `404 Not Found`: Recurso no encontrado
- `422 Unprocessable Entity`: Validación fallida
- `500 Internal Server Error`: Error del servidor

---

## Tipos de Datos Comunes

### Payment Types
- `business_cash`: Efectivo del negocio
- `business_transfer`: Transferencia del negocio
- `business_card`: Tarjeta del negocio
- `personal_cash`: Efectivo personal (requiere reembolso)
- `personal_card`: Tarjeta personal (requiere reembolso)
- `personal_transfer`: Transferencia personal (requiere reembolso)

### Expense Categories
- `supplies`: Insumos
- `services`: Servicios
- `utilities`: Servicios públicos
- `maintenance`: Mantenimiento
- `marketing`: Marketing
- `other`: Otros

### Account Types
- `digital`: Cuenta digital (ej: Mercado Pago)
- `physical_cash`: Efectivo físico (ej: Bóveda)
- `bank`: Cuenta bancaria

---

## Notas de Implementación Frontend

### Autenticación
1. Login → Guardar token en localStorage/sessionStorage
2. Agregar token en todas las requests subsecuentes
3. Si 401, redirigir a login
4. Implementar refresh token si es necesario

### Paginación
Endpoints que retornan listas suelen soportar:
```
?page=1&per_page=20
```

### Fechas
- Todas las fechas están en formato ISO 8601
- Zona horaria: UTC
- Formato: `YYYY-MM-DDTHH:mm:ss.sssZ`

### Errores
Formato estándar de error:
```json
{
  "error": "Mensaje de error",
  "errors": ["Error 1", "Error 2"],
  "field_errors": {
    "email": ["is invalid"],
    "amount": ["must be greater than 0"]
  }
}
```

---

**Última actualización:** 2025-11-18

**Versión API:** v1
