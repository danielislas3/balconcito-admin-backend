# 📐 Balconcito ERP - Diagramas Arquitectura

Este documento contiene diagramas visuales del sistema en formato Mermaid.

---

## 🗄️ Diagrama Entidad-Relación (ERD)

```mermaid
erDiagram
    USER ||--o{ TURN_CLOSURE : creates
    USER ||--o{ EXPENSE : creates
    USER ||--o{ REIMBURSEMENT : creates
    USER ||--o{ REIMBURSEMENT : receives
    
    ACCOUNT ||--o{ REIMBURSEMENT : "paid from"
    
    EXPENSE ||--o{ REIMBURSEMENT_EXPENSE : "included in"
    REIMBURSEMENT ||--o{ REIMBURSEMENT_EXPENSE : contains
    
    USER {
        bigint id PK
        string email UK
        string password_digest
        string name
        string role
        timestamp created_at
        timestamp updated_at
    }
    
    ACCOUNT {
        bigint id PK
        string name UK
        string account_type
        decimal current_balance
        text description
        timestamp created_at
        timestamp updated_at
    }
    
    TURN_CLOSURE {
        bigint id PK
        integer closure_number UK
        date report_date
        decimal cash_collected
        decimal transfer_income
        decimal card_income
        string closed_by
        decimal theoretical_cash
        decimal payments_withdrawals
        text notes
        bigint user_id FK
        timestamp created_at
        timestamp updated_at
    }
    
    EXPENSE {
        bigint id PK
        date expense_date
        decimal amount
        text description
        string category
        string payment_source
        string provider
        string receipt_photo_url
        boolean requires_reimbursement
        boolean reimbursed
        bigint user_id FK
        timestamp created_at
        timestamp updated_at
    }
    
    REIMBURSEMENT {
        bigint id PK
        date reimbursement_date
        bigint to_user_id FK
        decimal amount
        bigint from_account_id FK
        text notes
        bigint user_id FK
        timestamp created_at
        timestamp updated_at
    }
    
    REIMBURSEMENT_EXPENSE {
        bigint id PK
        bigint reimbursement_id FK
        bigint expense_id FK
        decimal amount
        timestamp created_at
        timestamp updated_at
    }
```

---

## 🔄 Flujo: Registrar Cierre de Turno

```mermaid
sequenceDiagram
    actor U as Daniel/Raúl
    participant F as Frontend
    participant API as Rails API
    participant DB as PostgreSQL
    participant A as Account
    
    U->>F: Lee ticket Loyverse
    U->>F: Llena formulario de cierre
    F->>API: POST /api/v1/turn_closures
    API->>DB: Crea TurnClosure
    DB-->>API: TurnClosure creado
    
    API->>API: Ejecuta callback after_create
    API->>DB: Busca Account "Caja Chica"
    API->>DB: UPDATE current_balance
    API->>DB: Busca Account "Mercado Pago"
    API->>DB: UPDATE current_balance
    
    API-->>F: 201 Created + datos
    F-->>U: ✅ Cierre registrado
    F->>F: Actualiza dashboard
```

---

## 💸 Flujo: Registrar Gasto (Efectivo del Negocio)

```mermaid
sequenceDiagram
    actor U as Daniel/Raúl
    participant F as Frontend
    participant API as Rails API
    participant DB as PostgreSQL
    
    U->>F: Llena formulario de gasto
    U->>F: Selecciona origen: "Efectivo (Bóveda)"
    F->>API: POST /api/v1/expenses
    API->>DB: Crea Expense
    DB-->>API: Expense creado
    
    API->>API: Ejecuta callback after_create
    API->>API: payment_source = cash_vault?
    API->>DB: Busca Account type=physical_cash
    API->>DB: DECREMENT current_balance
    
    API-->>F: 201 Created + datos
    F-->>U: ✅ Gasto registrado
    F->>F: Actualiza saldo de Bóveda
```

---

## 💳 Flujo: Registrar Gasto (Tarjeta Personal)

```mermaid
sequenceDiagram
    actor U as Daniel/Raúl
    participant F as Frontend
    participant API as Rails API
    participant DB as PostgreSQL
    
    U->>F: Llena formulario de gasto
    U->>F: Selecciona origen: "Tarjeta personal Daniel"
    F->>API: POST /api/v1/expenses
    API->>DB: Crea Expense
    DB-->>API: Expense creado
    
    API->>API: Ejecuta callback before_create
    API->>API: payment_source = daniel_card?
    API->>DB: SET requires_reimbursement = true
    
    Note over API: NO descuenta de ninguna cuenta
    
    API-->>F: 201 Created + datos
    F-->>U: ⚠️ Este gasto requiere reembolso
    F->>F: Actualiza "Reembolsos pendientes"
```

---

## 🔁 Flujo: Procesar Reembolso

```mermaid
sequenceDiagram
    actor U as Daniel/Raúl
    participant F as Frontend
    participant API as Rails API
    participant DB as PostgreSQL
    
    U->>F: Abre "Reembolsos pendientes"
    F->>API: GET /api/v1/expenses/pending_reimbursement
    API->>DB: SELECT expenses WHERE requires_reimbursement=true AND reimbursed=false
    DB-->>API: Lista de gastos
    API-->>F: Gastos pendientes por persona
    F-->>U: Muestra lista agrupada
    
    U->>F: Selecciona gastos a reembolsar
    U->>F: Indica cuenta origen (Mercado Pago)
    F->>API: POST /api/v1/reimbursements
    API->>DB: Crea Reimbursement
    API->>DB: Crea ReimbursementExpense (join)
    
    API->>API: Ejecuta callbacks
    API->>DB: UPDATE expenses SET reimbursed=true
    API->>DB: DECREMENT account balance
    
    API-->>F: 201 Created + datos
    F-->>U: ✅ Reembolso procesado
    F->>F: Actualiza dashboard
```

---

## 📊 Flujo: Ver Dashboard

```mermaid
sequenceDiagram
    actor U as Daniel/Raúl
    participant F as Frontend
    participant API as Rails API
    participant MC as MetricsCalculator
    participant DB as PostgreSQL
    
    U->>F: Abre Dashboard
    F->>F: Selecciona período (mes)
    
    par Llamadas paralelas al API
        F->>API: GET /dashboard/summary
        F->>API: GET /dashboard/profitability
        F->>API: GET /dashboard/break_even
        F->>API: GET /dashboard/cash_flow
        F->>API: GET /dashboard/expense_breakdown
    end
    
    API->>MC: new(start_date, end_date)
    MC->>DB: SELECT ingresos del período
    MC->>DB: SELECT gastos del período
    MC->>DB: SELECT saldos de cuentas
    DB-->>MC: Datos
    
    MC->>MC: Calcula métricas
    Note over MC: net_profit, net_margin<br/>cogs_%, labor_cost_%<br/>break_even_point<br/>cash_runway_days
    
    MC-->>API: Métricas calculadas
    API-->>F: JSON con todas las métricas
    
    F->>F: Renderiza componentes
    F-->>U: 📊 Dashboard completo
```

---

## 🏗️ Arquitectura del Sistema

```mermaid
graph TB
    subgraph "Frontend (Nuxt.js)"
        UI[Nuxt UI Components]
        Pages[Pages/Views]
        Store[Pinia Store]
        API_Client[API Client]
    end
    
    subgraph "Backend (Rails API)"
        Routes[Routes]
        Controllers[Controllers]
        Models[Models]
        Services[Services]
        Auth[JWT Auth]
    end
    
    subgraph "Database"
        PG[(PostgreSQL)]
    end
    
    subgraph "External Services (Futuro)"
        Loyverse[Loyverse API]
        MercadoPago[Mercado Pago API]
    end
    
    UI --> Pages
    Pages --> Store
    Store --> API_Client
    API_Client -->|HTTP/JSON| Routes
    
    Routes --> Auth
    Auth --> Controllers
    Controllers --> Services
    Controllers --> Models
    Models --> PG
    Services --> Models
    
    Controllers -.->|Milestone 4| Loyverse
    Controllers -.->|Opcional| MercadoPago
    
    style Frontend fill:#e1f5ff
    style Backend fill:#fff4e1
    style Database fill:#f0f0f0
    style External Services fill:#ffe1f0
```

---

## 🎯 Módulos del Sistema (Por Milestone)

```mermaid
graph LR
    subgraph "Milestone 1 - MVP Core"
        Auth[Autenticación]
        Accounts[Cuentas]
        TurnClosures[Cierres de Turno]
        Expenses[Gastos]
        Reimbursements[Reembolsos]
        Dashboard1[Dashboard Básico]
    end
    
    subgraph "Milestone 2 - Inteligencia"
        Debts[Deudas]
        Commissions[Comisiones MP]
        Dashboard2[Dashboard Avanzado]
        Comparisons[Comparativas]
        Alerts[Alertas]
    end
    
    subgraph "Milestone 3 - Proveedores"
        Providers[Proveedores]
        Products[Productos]
        PriceComparison[Comparación Precios]
    end
    
    subgraph "Milestone 4 - Loyverse"
        Integration[Integración API]
        ProductAnalytics[Análisis Productos]
        Reconciliation[Conciliación]
    end
    
    subgraph "Milestone 5 - RRHH"
        Employees[Empleados]
        Payroll[Nómina]
        TimeTracking[Control Horas]
    end
    
    Auth --> TurnClosures
    Auth --> Expenses
    Accounts --> TurnClosures
    Accounts --> Expenses
    Accounts --> Reimbursements
    Expenses --> Reimbursements
    TurnClosures --> Dashboard1
    Expenses --> Dashboard1
    Reimbursements --> Dashboard1
    
    Dashboard1 --> Dashboard2
    Expenses --> Debts
    TurnClosures --> Commissions
    
    Expenses --> Providers
    Providers --> Products
    Products --> PriceComparison
    
    TurnClosures --> Integration
    Integration --> ProductAnalytics
    Integration --> Reconciliation
    
    Expenses --> Payroll
    Employees --> Payroll
    Employees --> TimeTracking
    
    style Milestone 1 - MVP Core fill:#e1f5ff
    style Milestone 2 - Inteligencia fill:#fff4e1
    style Milestone 3 - Proveedores fill:#e1ffe1
    style Milestone 4 - Loyverse fill:#ffe1e1
    style Milestone 5 - RRHH fill:#f0e1ff
```

---

## 💰 Flujo de Dinero en el Sistema

```mermaid
graph TD
    Ventas[💰 Ventas del Día]
    
    Ventas -->|Efectivo| CajaChica[🏦 Caja Chica<br/>$1,000 + ventas]
    Ventas -->|Transferencia| MP[💳 Mercado Pago<br/>100% del monto]
    Ventas -->|Tarjeta| MP2[💳 Mercado Pago<br/>Monto - comisión]
    
    CajaChica -->|Gastos pequeños| GastosCaja[Hielo, agua, etc.]
    CajaChica -->|Fin del día| Boveda[🏛️ Bóveda<br/>Efectivo guardado]
    
    MP -->|Retiros| Boveda
    MP2 -->|Retiros| Boveda
    
    Boveda -->|Gastos grandes| GastosBoveda[Cerveza, insumos,<br/>pago proveedores]
    MP -->|Transferencias| GastosDigital[Servicios, pagos<br/>digitales]
    
    TarjetaPersonal[💳 Tarjeta Personal<br/>Daniel o Raúl] -->|Gastos| RequiereReembolso[⏳ Requiere Reembolso]
    
    RequiereReembolso -->|Se paga desde| MP
    RequiereReembolso -->|O desde| Boveda
    
    style Ventas fill:#90EE90
    style CajaChica fill:#87CEEB
    style Boveda fill:#DDA0DD
    style MP fill:#FFD700
    style MP2 fill:#FFD700
    style TarjetaPersonal fill:#FF6347
    style RequiereReembolso fill:#FFA500
```

---

## 📈 Cálculo de Métricas (Flujo de MetricsCalculator)

```mermaid
graph TD
    Start[Iniciar MetricsCalculator<br/>start_date, end_date]
    
    Start --> GetIncome[Obtener Ingresos<br/>TurnClosures del período]
    Start --> GetExpenses[Obtener Gastos<br/>Expenses del período]
    Start --> GetAccounts[Obtener Saldos<br/>Accounts actuales]
    
    GetIncome --> TotalIncome[total_income<br/>suma de todos los ingresos]
    GetExpenses --> ClassifyExpenses[Clasificar Gastos<br/>COGS / Fijos / Variables]
    
    ClassifyExpenses --> COGS[COGS Total<br/>Cerveza, alimentos, etc.]
    ClassifyExpenses --> Fixed[Costos Fijos<br/>Renta, nómina, servicios]
    ClassifyExpenses --> Variable[Costos Variables<br/>Mantenimiento, varios]
    
    TotalIncome --> NetProfit[✅ Utilidad Neta<br/>Ingresos - Gastos]
    COGS --> NetProfit
    Fixed --> NetProfit
    Variable --> NetProfit
    
    NetProfit --> NetMargin[✅ Margen Neto %<br/>Utilidad / Ingresos × 100]
    
    COGS --> COGSPercent[✅ COGS %<br/>COGS / Ingresos × 100]
    TotalIncome --> COGSPercent
    
    Fixed --> Payroll[Nómina Total]
    Payroll --> LaborCost[✅ Labor Cost %<br/>Nómina / Ingresos × 100]
    TotalIncome --> LaborCost
    
    COGSPercent --> ContribMargin[Margen de Contribución %<br/>100 - COGS%]
    Fixed --> BreakEven[✅ Punto de Equilibrio<br/>Costos Fijos / Margen Contrib%]
    ContribMargin --> BreakEven
    
    GetAccounts --> TotalCash[Total Efectivo Disponible<br/>MP + Bóveda + Caja Chica]
    Variable --> AvgDaily[Promedio Gastos Diarios<br/>Total Gastos / Días]
    Fixed --> AvgDaily
    COGS --> AvgDaily
    
    TotalCash --> CashRunway[✅ Cash Runway<br/>Efectivo / Promedio Diario]
    AvgDaily --> CashRunway
    
    style Start fill:#90EE90
    style NetProfit fill:#FFD700
    style NetMargin fill:#FFD700
    style COGSPercent fill:#87CEEB
    style LaborCost fill:#87CEEB
    style BreakEven fill:#DDA0DD
    style CashRunway fill:#FFA500
```

---

## 🎨 Estructura de Pantallas (Frontend)

```mermaid
graph TD
    Login[🔐 Login]
    Dashboard[📊 Dashboard Principal]
    
    Login -->|Auth exitosa| Dashboard
    
    Dashboard --> Summary[Resumen General]
    Dashboard --> Profitability[Rentabilidad]
    Dashboard --> BreakEven[Punto de Equilibrio]
    Dashboard --> CashFlow[Flujo de Efectivo]
    Dashboard --> ExpenseBreak[Desglose de Gastos]
    
    Dashboard --> NavCierres[📝 Cierres de Turno]
    Dashboard --> NavGastos[💸 Gastos]
    Dashboard --> NavReembolsos[💳 Reembolsos]
    Dashboard --> NavCuentas[🏦 Cuentas]
    
    NavCierres --> ListCierres[Lista de Cierres]
    NavCierres --> NewCierre[Nuevo Cierre]
    ListCierres --> EditCierre[Editar Cierre]
    
    NavGastos --> ListGastos[Lista de Gastos]
    NavGastos --> NewGasto[Nuevo Gasto]
    ListGastos --> EditGasto[Editar Gasto]
    
    NavReembolsos --> PendingReimb[Pendientes de Reembolsar]
    NavReembolsos --> HistoryReimb[Historial de Reembolsos]
    PendingReimb --> ProcessReimb[Procesar Reembolso]
    
    NavCuentas --> AccountsView[Ver Saldos]
    NavCuentas --> AdjustBalance[Ajustar Saldo Manual]
    
    style Login fill:#FF6347
    style Dashboard fill:#90EE90
    style Summary fill:#FFD700
    style Profitability fill:#87CEEB
    style BreakEven fill:#DDA0DD
    style CashFlow fill:#FFA500
```

---

## 🔄 Ciclo de Vida de un Día Operativo

```mermaid
sequenceDiagram
    participant David as 👤 David (Mesero)
    participant Balconcito as 🏪 Balconcito
    participant Loyverse as 💻 Loyverse POS
    participant Sistema as 🖥️ Sistema ERP
    participant Daniel as 👤 Daniel/Raúl
    
    Note over David,Daniel: 🌅 APERTURA (4:00 PM)
    David->>Balconcito: Llega a trabajar
    David->>Loyverse: Abre turno en POS
    Note over Loyverse: Fondo: $1,000
    
    Note over David,Daniel: 🍺 OPERACIÓN (4:00 PM - 1:00 AM)
    loop Durante el turno
        David->>Loyverse: Registra ventas
        David->>Balconcito: Gastos pequeños (hielo, agua)
        David->>Loyverse: Registra gastos como "Pagos/Salidas"
    end
    
    Note over David,Daniel: 🌙 CIERRE (1:00 AM)
    David->>Loyverse: Cierra turno
    Loyverse-->>David: Genera ticket #XX
    Note over Loyverse: Efectivo: $6,270<br/>Tarjetas: $2,015<br/>Transferencias: $550
    
    David->>Balconcito: Guarda efectivo en caja fuerte
    
    Note over David,Daniel: 📝 REGISTRO EN SISTEMA (Al día siguiente)
    Daniel->>Sistema: Abre formulario cierre
    Daniel->>Sistema: Lee datos del ticket
    Daniel->>Sistema: Registra cierre #XX
    Sistema->>Sistema: ✅ Actualiza Caja Chica
    Sistema->>Sistema: ✅ Actualiza Mercado Pago
    
    Daniel->>Sistema: Ve Dashboard actualizado
    Note over Sistema: Ingresos: $8,835<br/>Estado: ✅ Rentable
```

---

## 🚀 Roadmap Visual

```mermaid
timeline
    title Balconcito ERP - Roadmap de Desarrollo
    
    section Milestone 1 (2-3 semanas)
        MVP Core : Autenticación
                 : Cuentas
                 : Cierres de Turno
                 : Gastos
                 : Reembolsos
                 : Dashboard Básico
                 
    section Milestone 2 (2 semanas)
        Inteligencia : Deudas
                     : Comisiones MP
                     : Dashboard Avanzado
                     : Comparativas
                     : Alertas
                     
    section Milestone 3 (1-2 semanas)
        Proveedores : Catálogo
                    : Productos
                    : Comparación Precios
                    
    section Milestone 4 (2 semanas)
        Loyverse : Integración API
                 : Análisis Productos
                 : Conciliación Auto
                 
    section Milestone 5 (1-2 semanas)
        RRHH : Empleados
             : Nómina
             : Control Horas
```

---

## 📱 Mockup del Dashboard (Concepto)

```
┌─────────────────────────────────────────────────────────────┐
│  🍺 BALCONCITO ERP                      👤 Daniel  🚪 Logout │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  📊 Dashboard - Noviembre 2024                 [▼ Este mes]  │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ 💰 INGRESOS  │  │ 💸 GASTOS    │  │ ✅ UTILIDAD  │      │
│  │              │  │              │  │              │      │
│  │  $150,000    │  │  $120,000    │  │  $30,000     │      │
│  │  ↑ 15%       │  │  ↑ 8%        │  │  ↑ 25%       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 📈 Métricas de Rentabilidad                             ││
│  │                                                          ││
│  │  Margen Neto: 20% ━━━━━━━━━━━━━━━━━━━━ 20%             ││
│  │  COGS: 30%        ━━━━━━━━━━ 30%        ✅ Saludable   ││
│  │  Nómina: 16.67%   ━━━━━━ 16.67%         ✅ Óptimo      ││
│  └─────────────────────────────────────────────────────────┘│
│                                                               │
│  ┌──────────────────────┐  ┌─────────────────────────────┐ │
│  │ ⚖️ Punto Equilibrio  │  │ 🏦 Saldos Actuales          │ │
│  │                      │  │                             │ │
│  │ Meta: $83,333        │  │ • Mercado Pago: $45,000     │ │
│  │ Actual: $150,000     │  │ • Bóveda: $20,000           │ │
│  │ ✅ $66,667 arriba    │  │ • Caja Chica: $3,000        │ │
│  │                      │  │ ━━━━━━━━━━━━━━━━━━━━━━━━━ │ │
│  │ Alcanzado: Día 16    │  │ TOTAL: $68,000              │ │
│  └──────────────────────┘  │                             │ │
│                             │ 💰 Cash Runway: 17 días ⚠️  │ │
│                             └─────────────────────────────┘ │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 📊 Gastos por Categoría                                 ││
│  │                                                          ││
│  │  [Gráfica de dona]                                      ││
│  │                                                          ││
│  │  • Cerveza (20.83%) ━━━━━━━━━━━━ $25,000               ││
│  │  • Nómina (20.83%)  ━━━━━━━━━━━━ $25,000               ││
│  │  • Alimentos (12.5%) ━━━━━━ $15,000                    ││
│  │  • Otros (45.84%)    ━━━━━━━━━━━━━━━━━━━━ $55,000     ││
│  └─────────────────────────────────────────────────────────┘│
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

Estos diagramas están en formato **Mermaid**, que es compatible con:
- GitHub (se renderizan automáticamente)
- GitLab
- VS Code (con extensión)
- Notion
- Obsidian
- Y muchos otros tools de documentación

Para verlos renderizados, puedes usar:
- https://mermaid.live/
- O simplemente subirlos a GitHub