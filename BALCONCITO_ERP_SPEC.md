# 📊 Balconcito ERP - Especificación Técnica Completa

## 📋 Índice

1. [Contexto del Negocio](#contexto-del-negocio)
2. [Problema Actual](#problema-actual)
3. [Solución Propuesta](#solución-propuesta)
4. [Glosario de Términos Contables](#glosario-de-términos-contables)
5. [Stack Tecnológico](#stack-tecnológico)
6. [Arquitectura del Sistema](#arquitectura-del-sistema)
7. [Base de Datos - Modelos](#base-de-datos---modelos)
8. [API Endpoints](#api-endpoints)
9. [Flujos de Trabajo](#flujos-de-trabajo)
10. [Métricas y Cálculos](#métricas-y-cálculos)
11. [Plan de Implementación por Milestones](#plan-de-implementación-por-milestones)
12. [Preguntas y Respuestas del Negocio](#preguntas-y-respuestas-del-negocio)

---

## 🏪 Contexto del Negocio

### Sobre Balconcito

**Balconcito** es un bar-restaurante operado por Daniel y Raúl (co-propietarios). 

**Operación actual:**
- **Días de operación:** Martes a Domingo (horarios variables)
- **Personal:** 
  - David (mesero/asistente general) - pago semanal
  - Yahir (staff) - pago semanal  
  - Mamá (staff) - pago semanal
  - Daniel y Raúl (propietarios) - nómina fija

**Sistema de punto de venta:** Loyverse POS
- Terminal física: "meseros"
- Genera reportes de cierre de caja con número de ticket
- Acepta 3 métodos de pago: Efectivo, Tarjeta (terminal física), Transferencia (QR Mercado Pago)

### Flujo de Dinero Actual

El negocio maneja **tres "cuentas" principales**:

1. **Mercado Pago** (Cuenta digital/banco)
   - Aquí llegan las transferencias directas (QR/CVU) al 100%
   - Aquí llegan los pagos con tarjeta con descuento de comisión (~3.5% + fijo)
   - De aquí se retira efectivo para pagar proveedores o reponer bóveda
   - Es considerada la "bóveda digital"

2. **Bóveda** (Efectivo guardado físicamente)
   - Todo el efectivo acumulado del negocio
   - De aquí se sacan $1,000 para el fondo de caja chica cada día
   - De aquí se pagan compras grandes (cerveza, insumos mayores)
   - Se alimenta con retiros de Mercado Pago o con efectivo de cierres

3. **Caja Chica** (Efectivo operativo del día)
   - Siempre tiene un fondo fijo de **$1,000 pesos**
   - Más el efectivo de las ventas del día
   - De aquí se pagan gastos pequeños del día (hielo, agua, etc.)
   - Al final del día, el excedente va a Bóveda

### Deudas y Compromisos Financieros

**Deudas actuales:**
- Deuda de inversión inicial (Daniel, Raúl, inversionista externo)
- Saldos de tarjetas de crédito:
  - 1 tarjeta del negocio
  - 2 tarjetas personales de Daniel
  - Tarjetas personales de Raúl (si las usa)

**Política de deudas:** Se paga deuda cuando hay excedentes. No hay pagos periódicos obligatorios aún.

### Gastos con Tarjetas Personales

Cuando Daniel o Raúl hacen gastos del negocio con sus tarjetas personales:
1. Se registra el gasto en el sistema
2. Se marca como "requiere reembolso"
3. Después se les reembolsa desde Mercado Pago o Bóveda
4. **Problema actual:** No hay forma de trackear cuánto se debe a cada uno

---

## 🔴 Problema Actual

### Sistema Actual (Lo que se quiere reemplazar)

**Loyverse POS:**
- ✅ Funciona bien para punto de venta
- ✅ Genera tickets de cierre con datos útiles
- ❌ No tiene visión financiera completa del negocio
- ❌ No puede consolidar gastos externos
- ❌ No calcula métricas de rentabilidad

**2 Formularios de Google + Excel:**

**Formulario 1 - Cierres de Turno:**
Captura manualmente datos del ticket de Loyverse:
- Número de cierre de caja
- Fecha del reporte
- Cobros en efectivo
- Ingresos por transferencia (brutos)
- Ingresos por tarjeta (brutos)
- Cerrado por (nombre del empleado)
- Pagos/Salidas (del ticket)
- Efectivo teórico
- Notas opcionales

**Formulario 2 - Gastos:**
Registra todos los gastos del negocio:
- Fecha del gasto
- Monto
- Descripción
- Categoría (cerveza, alimentos, nómina, etc.)
- Origen del pago (caja chica, bóveda, mercado pago, tarjetas)
- Proveedor
- Foto del ticket (opcional)

**Dolor principal: Doble registro**
- Los gastos que se pagan de caja chica se registran en Loyverse (como "Pagos/Salidas")
- Pero también hay que registrarlos en el formulario de gastos para tener la categorización
- Esto genera trabajo doble y posibilidad de errores

### Problemas Específicos

1. **No hay visibilidad en tiempo real** de cuánto dinero hay en cada cuenta
2. **No se pueden calcular métricas clave** (rentabilidad, punto de equilibrio, etc.)
3. **Doble trabajo** al registrar gastos de caja chica
4. **No se trackean reembolsos pendientes** a Daniel y Raúl
5. **No hay proyecciones** de flujo de efectivo
6. **No se puede comparar** un mes vs otro fácilmente
7. **Excel "engorroso"** que es difícil de mantener

---

## ✅ Solución Propuesta

### Objetivo General

Crear un **sistema de administración centralizado (ERP)** que sea la **fuente única de verdad** para todas las finanzas de Balconcito.

### Qué Resolverá el Sistema

**Reemplazar:**
- Los 2 formularios de Google
- El Excel de contabilidad manual

**Proveer:**
- Registro fácil de cierres de turno (un solo lugar)
- Registro fácil de gastos (un solo lugar)
- Dashboard con métricas clave en tiempo real
- Trackeo automático de saldos de cuentas
- Sistema de reembolsos (para tarjetas personales)
- Métricas de rentabilidad y eficiencia
- Comparativas entre períodos
- Integración futura con Loyverse API (automatización)

### Principios de Diseño

1. **Escalabilidad:** Desarrollo por módulos/milestones
2. **Simplicidad:** Interfaz intuitiva para usuarios no técnicos
3. **Automatización:** Calcular todo automáticamente, mínimo input manual
4. **Visibilidad:** Dashboard claro con las métricas que importan
5. **Flexibilidad:** Fácil de modificar y extender en el futuro

---

## 📖 Glosario de Términos Contables

> **Nota:** Daniel y Raúl no tienen background contable, por lo que los términos deben ser claros y simples.

### Métricas de Rentabilidad (¿Estamos ganando dinero?)

#### 1. Utilidad Neta (Net Profit) 💰
**Qué es:** El dinero que te queda después de pagar TODO. Es tu ganancia real.

**Fórmula:** 
```
Utilidad Neta = Ingresos Totales - Egresos Totales
```

**Ejemplo:** 
- Vendiste $100,000 en el mes
- Gastaste $80,000 en todo (insumos, nómina, renta, etc.)
- Tu Utilidad Neta = $20,000

**Por qué importa:** Si este número es negativo, estás perdiendo dinero. Si es positivo, estás ganando.

---

#### 2. Margen de Ganancia Neta (Net Profit Margin) 📊
**Qué es:** De cada peso que vendes, qué porcentaje se queda como ganancia pura.

**Fórmula:**
```
Margen Neto = (Utilidad Neta / Ingresos Totales) × 100
```

**Ejemplo:**
- Vendiste $100,000
- Utilidad Neta: $20,000
- Margen Neto = 20%

Significa que de cada peso vendido, 20 centavos son ganancia.

**Por qué importa:** Te permite comparar meses con diferentes niveles de venta. Un mes puedes vender más pero ganar menos porcentaje.

---

### Métricas de Eficiencia (¿Dónde se va el dinero?)

#### 3. Costo de Insumos / COGS (Cost of Goods Sold) 🍺
**Qué es:** Cuánto te cuesta la comida y bebida que vendes, como porcentaje de tus ventas.

**Fórmula:**
```
COGS % = (Costo de Insumos / Ingresos Totales) × 100
```

**Qué incluye:**
- Cerveza
- Cerveza de barril
- Vinos y licores
- Refrescos y jugos
- Alimentos (botanas, ingredientes)
- Desechables, hielo, insumos secos

**Ejemplo:**
- Vendiste $100,000
- Gastaste $30,000 en cerveza, comida, hielo, etc.
- COGS = 30%

**Por qué importa:** 
- Si sube mucho = o tus proveedores subieron precios, o hay desperdicio/robo
- Para bares, lo ideal es mantenerlo entre 25-35%

---

#### 4. Costo de Nómina (Labor Cost) 👥
**Qué es:** Cuánto te cuesta tu personal, como porcentaje de tus ventas.

**Fórmula:**
```
Labor Cost % = (Costo de Nómina / Ingresos Totales) × 100
```

**Ejemplo:**
- Vendiste $100,000
- Pagaste $20,000 en sueldos
- Labor Cost = 20%

**Por qué importa:** Te dice si tienes el personal adecuado para tu nivel de ventas.

---

### Métricas de Supervivencia (¿Podemos pagar las cuentas?)

#### 5. Punto de Equilibrio (Break-Even Point) ⚖️
**Qué es:** La cantidad EXACTA que necesitas vender para no ganar ni perder. Es tu meta de supervivencia.

**Conceptos previos:**

**Costos Fijos:** Lo que pagas sin importar cuánto vendas
- Renta: siempre pagas lo mismo
- Sueldos fijos: siempre pagas lo mismo
- Servicios (luz, agua, gas): más o menos constantes

**Costos Variables:** Lo que te cuesta MÁS si vendes MÁS
- Insumos (cerveza, comida): si vendes más, compras más
- Desechables: si vendes más, usas más vasos/platos

**Margen de Contribución:** De cada peso vendido, cuánto queda para cubrir costos fijos después de pagar costos variables.

**Fórmula:**
```
Punto de Equilibrio = Costos Fijos / (Margen de Contribución %)
```

**Ejemplo:**
- Costos Fijos del mes: $50,000 (renta, sueldos, servicios)
- Margen de Contribución: 60% (de cada peso, 60 centavos quedan después de pagar insumos)
- Punto de Equilibrio = $50,000 / 0.60 = $83,333

Esto significa: **necesitas vender $83,333 al mes solo para no perder**.
- La venta #1 hasta la venta #83,333 → solo cubren costos
- La venta #83,334 en adelante → es ganancia pura

**Por qué importa:** Es tu meta mínima. Si no llegas a este número, estás perdiendo dinero.

---

#### 6. Días de Efectivo (Cash Runway) 🏃‍♂️
**Qué es:** Si tus ventas bajaran a cero mañana, ¿cuántos días podrías seguir operando antes de quebrar?

**Fórmula:**
```
Cash Runway = Efectivo Total Disponible / Promedio de Gastos Diarios
```

**Ejemplo:**
- Tienes $60,000 en todas tus cuentas (Mercado Pago + Bóveda + Caja Chica)
- Gastas en promedio $3,000 por día
- Cash Runway = 20 días

Significa: si no entra ni un peso más, podrías operar 20 días.

**Por qué importa:** Es tu "colchón de seguridad". Si este número es muy bajo (<15 días), estás en riesgo.

---

## 🛠️ Stack Tecnológico

### Backend
- **Framework:** Ruby on Rails 8+ (modo API)
- **Base de datos:** PostgreSQL
- **Autenticación:** Devise + JWT
- **Tests:** RSpec
- **Deploy:** Railway / Render (sugerido)

### Frontend  
- **Framework:** Nuxt.js 4
- **UI Library:** Nuxt UI
- **Deploy:** Vercel (sugerido)

### Integraciones Futuras
- **Loyverse API:** Para importar datos de ventas automáticamente
- **Mercado Pago API:** Para obtener saldos y transacciones en tiempo real (opcional)

---

## 🏗️ Arquitectura del Sistema

### Módulos Principales

```
┌─────────────────────────────────────────────────────┐
│                   BALCONCITO ERP                    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │   Auth      │  │  Accounts   │  │ Dashboard  │ │
│  │  (Users)    │  │  (Cuentas)  │  │ (Métricas) │ │
│  └─────────────┘  └─────────────┘  └────────────┘ │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │Turn Closures│  │  Expenses   │  │Reimbursem. │ │
│  │  (Cierres)  │  │  (Gastos)   │  │(Reembolsos)│ │
│  └─────────────┘  └─────────────┘  └────────────┘ │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │   Debts     │  │  Providers  │  │  Employees │ │
│  │  (Deudas)   │  │(Proveedores)│  │ (Nómina)   │ │
│  └─────────────┘  └─────────────┘  └────────────┘ │
│         ▲                                           │
│         └──────── Milestones 2-5 ──────────┘       │
└─────────────────────────────────────────────────────┘
```

---

## 🗄️ Base de Datos - Modelos

### Modelo: User (Usuarios)

**Propósito:** Usuarios que pueden acceder al sistema.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  
  # Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  
  # Associations
  has_many :turn_closures
  has_many :expenses
  has_many :reimbursements_received, class_name: 'Reimbursement', foreign_key: 'to_user_id'
  has_many :reimbursements_created, class_name: 'Reimbursement', foreign_key: 'user_id'
end
```

**Tabla: users**
```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_digest VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(50) DEFAULT 'admin', -- admin, manager, employee
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

**Usuarios iniciales:**
- Daniel (admin)
- Raúl (admin)

---

### Modelo: Account (Cuentas de Dinero)

**Propósito:** Representa las "bolsas" donde está el dinero del negocio.

```ruby
# app/models/account.rb
class Account < ApplicationRecord
  # Enums
  enum account_type: {
    digital: 'digital',           # Mercado Pago
    physical_cash: 'physical_cash', # Bóveda
    petty_cash: 'petty_cash'        # Caja Chica
  }
  
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :account_type, presence: true
  validates :current_balance, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :total_balance, -> { sum(:current_balance) }
end
```

**Tabla: accounts**
```sql
CREATE TABLE accounts (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE, -- 'Mercado Pago', 'Bóveda', 'Caja Chica'
  account_type VARCHAR(50) NOT NULL, -- 'digital', 'physical_cash', 'petty_cash'
  current_balance DECIMAL(15,2) DEFAULT 0.00,
  description TEXT,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

**Registros iniciales:**
```ruby
Account.create([
  { name: 'Mercado Pago', account_type: 'digital', current_balance: 0 },
  { name: 'Bóveda', account_type: 'physical_cash', current_balance: 0 },
  { name: 'Caja Chica', account_type: 'petty_cash', current_balance: 1000 } # Siempre tiene $1,000
])
```

---

### Modelo: TurnClosure (Cierres de Turno)

**Propósito:** Registra cada cierre de caja del día, basado en el ticket de Loyverse.

```ruby
# app/models/turn_closure.rb
class TurnClosure < ApplicationRecord
  belongs_to :user # Quién lo registró en el sistema
  
  # Validations
  validates :closure_number, presence: true, uniqueness: true
  validates :report_date, presence: true
  validates :closed_by, presence: true
  validates :cash_collected, :transfer_income, :card_income, 
            :theoretical_cash, :payments_withdrawals,
            numericality: { greater_than_or_equal_to: 0 }
  
  # Callbacks
  after_create :update_account_balances
  after_update :update_account_balances
  
  # Instance methods
  def total_income
    cash_collected + transfer_income + card_income
  end
  
  private
  
  def update_account_balances
    # Actualizar Caja Chica
    petty_cash = Account.find_by(account_type: 'petty_cash')
    petty_cash.update(
      current_balance: 1000 + cash_collected - payments_withdrawals
    )
    
    # Actualizar Mercado Pago
    mercadopago = Account.find_by(name: 'Mercado Pago')
    # Nota: En Milestone 2 aquí se restará la comisión de tarjeta
    mercadopago.increment!(:current_balance, transfer_income + card_income)
  end
end
```

**Tabla: turn_closures**
```sql
CREATE TABLE turn_closures (
  id BIGSERIAL PRIMARY KEY,
  closure_number INTEGER NOT NULL UNIQUE, -- Del ticket Loyverse
  report_date DATE NOT NULL,              -- Fecha que abrió el turno
  cash_collected DECIMAL(15,2) DEFAULT 0.00,
  transfer_income DECIMAL(15,2) DEFAULT 0.00,  -- Ingresos BRUTOS
  card_income DECIMAL(15,2) DEFAULT 0.00,      -- Ingresos BRUTOS
  closed_by VARCHAR(100) NOT NULL,        -- David, Raúl, Daniel
  theoretical_cash DECIMAL(15,2) DEFAULT 0.00,
  payments_withdrawals DECIMAL(15,2) DEFAULT 0.00, -- Pagos/Salidas del ticket
  notes TEXT,
  user_id BIGINT REFERENCES users(id),    -- Quién lo registró
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_turn_closures_report_date ON turn_closures(report_date);
CREATE INDEX idx_turn_closures_user ON turn_closures(user_id);
```

---

### Modelo: Expense (Gastos)

**Propósito:** Registra todos los gastos del negocio.

```ruby
# app/models/expense.rb
class Expense < ApplicationRecord
  belongs_to :user # Quién lo registró
  has_many :reimbursement_expenses
  has_many :reimbursements, through: :reimbursement_expenses
  
  # Enums
  enum category: {
    # COGS (Cost of Goods Sold) - Costo de lo que vendes
    beer: 'cerveza',
    draft_beer: 'cerveza_barril',
    wines_liquors: 'vinos_licores',
    sodas_juices: 'refrescos_jugos',
    food: 'alimentos',
    disposables: 'desechables',
    ice: 'hielo',
    dry_supplies: 'insumos_secos',
    
    # Costos Fijos
    rent: 'renta',
    payroll: 'nomina',
    utilities: 'servicios', # luz, agua, gas
    financial: 'gastos_financieros', # comisiones Mercado Pago
    debt_payment: 'pago_deuda',
    
    # Costos Variables
    maintenance: 'mantenimiento',
    staff_expenses: 'gastos_staff',
    miscellaneous: 'gastos_varios'
  }
  
  enum payment_source: {
    cash_petty: 'efectivo_caja_chica',
    cash_vault: 'efectivo_boveda',
    mercadopago_transfer: 'transferencia_negocio',
    business_card: 'tarjeta_negocio',
    daniel_card: 'tarjeta_daniel',
    raul_card: 'tarjeta_raul'
  }
  
  # Validations
  validates :expense_date, :amount, :description, :category, :payment_source, presence: true
  validates :amount, numericality: { greater_than: 0 }
  
  # Scopes
  scope :pending_reimbursement, -> { where(requires_reimbursement: true, reimbursed: false) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }
  
  # Callbacks
  before_create :check_if_requires_reimbursement
  after_create :update_account_balance
  
  # Instance methods
  def cost_type
    case category.to_sym
    when :beer, :draft_beer, :wines_liquors, :sodas_juices, :food, 
         :disposables, :ice, :dry_supplies
      'cogs' # Cost of Goods Sold
    when :rent, :payroll, :utilities, :financial, :debt_payment
      'fixed' # Costos Fijos
    when :maintenance, :staff_expenses, :miscellaneous
      'variable' # Costos Variables
    end
  end
  
  private
  
  def check_if_requires_reimbursement
    self.requires_reimbursement = daniel_card? || raul_card?
  end
  
  def update_account_balance
    return if requires_reimbursement # Las tarjetas personales no afectan cuentas del negocio
    
    account = case payment_source.to_sym
              when :cash_petty then Account.find_by(account_type: 'petty_cash')
              when :cash_vault then Account.find_by(account_type: 'physical_cash')
              when :mercadopago_transfer then Account.find_by(name: 'Mercado Pago')
              when :business_card then nil # TODO: Implementar tarjeta de crédito del negocio
              end
    
    account&.decrement!(:current_balance, amount)
  end
end
```

**Tabla: expenses**
```sql
CREATE TABLE expenses (
  id BIGSERIAL PRIMARY KEY,
  expense_date DATE NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(50) NOT NULL,
  payment_source VARCHAR(50) NOT NULL,
  provider VARCHAR(255),              -- Nombre del proveedor (texto libre)
  receipt_photo_url VARCHAR(500),     -- URL de foto del ticket
  requires_reimbursement BOOLEAN DEFAULT false,
  reimbursed BOOLEAN DEFAULT false,
  user_id BIGINT REFERENCES users(id),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category);
CREATE INDEX idx_expenses_payment_source ON expenses(payment_source);
CREATE INDEX idx_expenses_reimbursement ON expenses(requires_reimbursement, reimbursed);
```

---

### Modelo: Reimbursement (Reembolsos)

**Propósito:** Registra cuando se paga a Daniel o Raúl por gastos hechos con tarjetas personales.

```ruby
# app/models/reimbursement.rb
class Reimbursement < ApplicationRecord
  belongs_to :to_user, class_name: 'User' # A quién se le paga
  belongs_to :from_account, class_name: 'Account' # De qué cuenta sale
  belongs_to :user # Quién registró el reembolso
  
  has_many :reimbursement_expenses
  has_many :expenses, through: :reimbursement_expenses
  
  # Validations
  validates :reimbursement_date, :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
  
  # Callbacks
  after_create :mark_expenses_as_reimbursed
  after_create :update_account_balance
  
  private
  
  def mark_expenses_as_reimbursed
    expenses.update_all(reimbursed: true)
  end
  
  def update_account_balance
    from_account.decrement!(:current_balance, amount)
  end
end
```

**Tabla: reimbursements**
```sql
CREATE TABLE reimbursements (
  id BIGSERIAL PRIMARY KEY,
  reimbursement_date DATE NOT NULL,
  to_user_id BIGINT REFERENCES users(id) NOT NULL, -- A quién se le paga
  amount DECIMAL(15,2) NOT NULL,
  from_account_id BIGINT REFERENCES accounts(id) NOT NULL, -- De qué cuenta
  notes TEXT,
  user_id BIGINT REFERENCES users(id),  -- Quién lo registró
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_reimbursements_to_user ON reimbursements(to_user_id);
CREATE INDEX idx_reimbursements_date ON reimbursements(reimbursement_date);
```

**Tabla: reimbursement_expenses** (join table)
```sql
CREATE TABLE reimbursement_expenses (
  id BIGSERIAL PRIMARY KEY,
  reimbursement_id BIGINT REFERENCES reimbursements(id) ON DELETE CASCADE,
  expense_id BIGINT REFERENCES expenses(id) ON DELETE CASCADE,
  amount DECIMAL(15,2) NOT NULL, -- Por si un reembolso cubre parcialmente varios gastos
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_reimbursement_expenses_reimbursement ON reimbursement_expenses(reimbursement_id);
CREATE INDEX idx_reimbursement_expenses_expense ON reimbursement_expenses(expense_id);
```

---

### Diagrama de Relaciones (Milestone 1)

```
┌──────────┐
│  User    │
└────┬─────┘
     │
     │ has_many
     ├──────────────┐
     │              │
     ▼              ▼
┌────────────┐  ┌──────────┐
│TurnClosure │  │ Expense  │
└────────────┘  └────┬─────┘
                     │
                     │ belongs_to (when reimbursement)
                     ▼
                ┌──────────────┐
                │ Reimbursement│◄────────┐
                └───────┬──────┘         │
                        │                │
                        │ belongs_to     │ belongs_to
                        ▼                │
                   ┌─────────┐          │
                   │ Account │──────────┘
                   └─────────┘
```

---

## 🔌 API Endpoints

### Autenticación

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
```

#### POST /api/v1/auth/login

**Request:**
```json
{
  "email": "daniel@balconcito.com",
  "password": "password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "daniel@balconcito.com",
    "name": "Daniel",
    "role": "admin"
  }
}
```

---

### Cuentas (Accounts)

```
GET    /api/v1/accounts
GET    /api/v1/accounts/:id
PATCH  /api/v1/accounts/:id
```

#### GET /api/v1/accounts

**Response (200 OK):**
```json
{
  "accounts": [
    {
      "id": 1,
      "name": "Mercado Pago",
      "account_type": "digital",
      "current_balance": 45000.00,
      "description": null
    },
    {
      "id": 2,
      "name": "Bóveda",
      "account_type": "physical_cash",
      "current_balance": 20000.00,
      "description": null
    },
    {
      "id": 3,
      "name": "Caja Chica",
      "account_type": "petty_cash",
      "current_balance": 3000.00,
      "description": "Fondo fijo $1,000 + ventas del día"
    }
  ],
  "total_balance": 68000.00
}
```

#### PATCH /api/v1/accounts/:id

**Uso:** Ajustar balance manualmente (ej: si retiran efectivo de Mercado Pago para llevarlo a Bóveda)

**Request:**
```json
{
  "current_balance": 50000.00,
  "notes": "Retiro de $5,000 para pagar proveedor"
}
```

---

### Cierres de Turno (Turn Closures)

```
GET    /api/v1/turn_closures
POST   /api/v1/turn_closures
GET    /api/v1/turn_closures/:id
PATCH  /api/v1/turn_closures/:id
DELETE /api/v1/turn_closures/:id
```

#### GET /api/v1/turn_closures

**Query params:**
- `?date_from=2024-11-01` - Filtrar desde fecha
- `?date_to=2024-11-30` - Filtrar hasta fecha
- `?closed_by=David` - Filtrar por quien cerró

**Response (200 OK):**
```json
{
  "turn_closures": [
    {
      "id": 1,
      "closure_number": 59,
      "report_date": "2024-11-13",
      "cash_collected": 2250.00,
      "transfer_income": 0.00,
      "card_income": 475.00,
      "closed_by": "David",
      "theoretical_cash": 3136.00,
      "payments_withdrawals": 114.00,
      "total_income": 2725.00,
      "notes": null,
      "created_at": "2024-11-14T01:33:00Z"
    }
  ],
  "summary": {
    "total_closures": 1,
    "total_income": 2725.00,
    "total_cash": 2250.00,
    "total_transfers": 0.00,
    "total_cards": 475.00
  }
}
```

#### POST /api/v1/turn_closures

**Request:**
```json
{
  "closure_number": 60,
  "report_date": "2024-11-14",
  "cash_collected": 6270.20,
  "transfer_income": 550.00,
  "card_income": 2015.00,
  "closed_by": "David",
  "theoretical_cash": 7270.20,
  "payments_withdrawals": 0.00,
  "notes": ""
}
```

**Response (201 Created):**
```json
{
  "turn_closure": {
    "id": 2,
    "closure_number": 60,
    "report_date": "2024-11-14",
    "cash_collected": 6270.20,
    "transfer_income": 550.00,
    "card_income": 2015.00,
    "closed_by": "David",
    "theoretical_cash": 7270.20,
    "payments_withdrawals": 0.00,
    "total_income": 8835.20,
    "notes": "",
    "created_at": "2024-11-15T02:59:00Z"
  },
  "message": "Cierre registrado exitosamente"
}
```

---

### Gastos (Expenses)

```
GET    /api/v1/expenses
POST   /api/v1/expenses
GET    /api/v1/expenses/:id
PATCH  /api/v1/expenses/:id
DELETE /api/v1/expenses/:id
GET    /api/v1/expenses/pending_reimbursement
```

#### GET /api/v1/expenses

**Query params:**
- `?date_from=2024-11-01`
- `?date_to=2024-11-30`
- `?category=cerveza`
- `?payment_source=efectivo_caja_chica`
- `?requires_reimbursement=true`

**Response (200 OK):**
```json
{
  "expenses": [
    {
      "id": 1,
      "expense_date": "2024-11-04",
      "amount": 85.00,
      "description": "destapa caños",
      "category": "mantenimiento",
      "payment_source": "efectivo_caja_chica",
      "provider": null,
      "receipt_photo_url": null,
      "requires_reimbursement": false,
      "reimbursed": false,
      "created_at": "2024-11-04T22:02:02Z"
    }
  ],
  "summary": {
    "total_expenses": 85.00,
    "count": 1
  }
}
```

#### POST /api/v1/expenses

**Request:**
```json
{
  "expense_date": "2024-11-15",
  "amount": 3633.00,
  "description": "Cerveza corona",
  "category": "cerveza",
  "payment_source": "efectivo_boveda",
  "provider": "Central",
  "receipt_photo_url": null
}
```

**Response (201 Created):**
```json
{
  "expense": {
    "id": 15,
    "expense_date": "2024-11-15",
    "amount": 3633.00,
    "description": "Cerveza corona",
    "category": "cerveza",
    "payment_source": "efectivo_boveda",
    "provider": "Central",
    "receipt_photo_url": null,
    "requires_reimbursement": false,
    "reimbursed": false,
    "cost_type": "cogs"
  },
  "message": "Gasto registrado exitosamente"
}
```

#### GET /api/v1/expenses/pending_reimbursement

**Uso:** Ver gastos con tarjeta personal que aún no se han reembolsado.

**Response (200 OK):**
```json
{
  "pending_reimbursements": {
    "daniel": {
      "expenses": [
        {
          "id": 5,
          "expense_date": "2024-11-10",
          "amount": 500.00,
          "description": "Compra de insumos",
          "payment_source": "tarjeta_daniel"
        }
      ],
      "total_amount": 500.00
    },
    "raul": {
      "expenses": [],
      "total_amount": 0.00
    }
  },
  "grand_total": 500.00
}
```

---

### Reembolsos (Reimbursements)

```
GET    /api/v1/reimbursements
POST   /api/v1/reimbursements
GET    /api/v1/reimbursements/:id
```

#### POST /api/v1/reimbursements

**Request:**
```json
{
  "reimbursement_date": "2024-11-15",
  "to_user_id": 1, // Daniel's user ID
  "from_account_id": 1, // Mercado Pago
  "amount": 500.00,
  "expense_ids": [5, 6], // IDs de los gastos que se están reembolsando
  "notes": "Reembolso por compras de la semana"
}
```

**Response (201 Created):**
```json
{
  "reimbursement": {
    "id": 1,
    "reimbursement_date": "2024-11-15",
    "to_user": {
      "id": 1,
      "name": "Daniel"
    },
    "from_account": {
      "id": 1,
      "name": "Mercado Pago"
    },
    "amount": 500.00,
    "expenses_count": 2,
    "notes": "Reembolso por compras de la semana"
  },
  "message": "Reembolso registrado exitosamente"
}
```

---

### Dashboard (Métricas)

```
GET    /api/v1/dashboard/summary
GET    /api/v1/dashboard/profitability
GET    /api/v1/dashboard/break_even
GET    /api/v1/dashboard/cash_flow
GET    /api/v1/dashboard/expense_breakdown
```

#### GET /api/v1/dashboard/summary

**Query params:**
- `?period=day|week|month` (default: month)
- `?date=2024-11-15` (default: today)

**Response (200 OK):**
```json
{
  "period": "month",
  "date": "2024-11-15",
  "date_range": {
    "start": "2024-11-01",
    "end": "2024-11-30"
  },
  
  "income": {
    "total": 150000.00,
    "cash": 90000.00,
    "transfers": 30000.00,
    "cards": 30000.00
  },
  
  "expenses": {
    "total": 120000.00,
    "cogs": 45000.00,
    "fixed": 50000.00,
    "variable": 25000.00
  },
  
  "balance": 30000.00,
  
  "accounts": {
    "mercadopago": 45000.00,
    "boveda": 20000.00,
    "caja_chica": 3000.00,
    "total": 68000.00
  },
  
  "pending_reimbursements": {
    "daniel": 500.00,
    "raul": 0.00,
    "total": 500.00
  }
}
```

#### GET /api/v1/dashboard/profitability

**Uso:** Métricas de rentabilidad (Utilidad Neta, Margen Neto, COGS%, Labor Cost%)

**Query params:** (mismos que /summary)

**Response (200 OK):**
```json
{
  "period": "month",
  "date_range": {
    "start": "2024-11-01",
    "end": "2024-11-30"
  },
  
  "metrics": {
    "net_profit": {
      "value": 30000.00,
      "description": "Utilidad Neta - Tu ganancia después de pagar todo"
    },
    "net_margin": {
      "value": 20.0,
      "description": "Margen de Ganancia Neta - % de cada peso que es ganancia",
      "unit": "%"
    },
    "cogs_percentage": {
      "value": 30.0,
      "amount": 45000.00,
      "description": "Costo de Insumos - % de ventas que gastaste en productos",
      "unit": "%",
      "status": "good" // good / warning / bad (basado en rangos ideales)
    },
    "labor_cost_percentage": {
      "value": 16.67,
      "amount": 25000.00,
      "description": "Costo de Nómina - % de ventas que gastaste en personal",
      "unit": "%",
      "status": "good"
    }
  },
  
  "breakdown": {
    "total_income": 150000.00,
    "total_expenses": 120000.00,
    "cogs_total": 45000.00,
    "payroll_total": 25000.00,
    "other_expenses": 50000.00
  }
}
```

#### GET /api/v1/dashboard/break_even

**Uso:** Cálculo del Punto de Equilibrio

**Query params:** (mismos que /summary)

**Response (200 OK):**
```json
{
  "period": "month",
  "date_range": {
    "start": "2024-11-01",
    "end": "2024-11-30"
  },
  
  "metrics": {
    "fixed_costs_total": 50000.00,
    "variable_costs_total": 70000.00,
    "cogs_percentage": 30.0,
    "contribution_margin_percentage": 70.0,
    
    "break_even_point": {
      "value": 71428.57,
      "description": "Punto de Equilibrio - Lo mínimo que necesitas vender para no perder"
    },
    
    "current_sales": 150000.00,
    
    "safety_margin": {
      "value": 78571.43,
      "description": "Margen de Seguridad - Cuánto estás por encima del punto de equilibrio",
      "percentage": 52.38
    },
    
    "days_to_break_even": 14,
    "description": "En el día 14 del mes llegaste al punto de equilibrio"
  },
  
  "status": "above_break_even", // above_break_even / below_break_even / at_break_even
  
  "explanation": "Necesitas vender $71,428.57 al mes solo para cubrir costos. Ya superaste esa meta por $78,571.43"
}
```

#### GET /api/v1/dashboard/cash_flow

**Uso:** Análisis de flujo de efectivo y días de supervivencia

**Query params:** (mismos que /summary)

**Response (200 OK):**
```json
{
  "period": "month",
  "date_range": {
    "start": "2024-11-01",
    "end": "2024-11-30"
  },
  
  "cash_accounts": {
    "mercadopago": {
      "balance": 45000.00,
      "type": "digital"
    },
    "boveda": {
      "balance": 20000.00,
      "type": "physical_cash"
    },
    "caja_chica": {
      "balance": 3000.00,
      "type": "petty_cash"
    },
    "total_cash": 68000.00
  },
  
  "metrics": {
    "average_daily_expenses": 4000.00,
    
    "cash_runway_days": {
      "value": 17,
      "description": "Días de Efectivo - Si no vendieran nada, podrían operar 17 días",
      "status": "warning" // good (>30 días) / warning (15-30) / critical (<15)
    }
  },
  
  "expense_distribution": {
    "cash": {
      "amount": 35000.00,
      "percentage": 29.17,
      "description": "Gastos pagados en efectivo"
    },
    "digital": {
      "amount": 85000.00,
      "percentage": 70.83,
      "description": "Gastos pagados digitalmente (transferencias/tarjetas)"
    }
  },
  
  "explanation": "Con $68,000 disponibles y gastando $4,000 al día en promedio, pueden operar 17 días sin ingresos"
}
```

#### GET /api/v1/dashboard/expense_breakdown

**Uso:** Desglose detallado de gastos por categoría

**Query params:** (mismos que /summary)

**Response (200 OK):**
```json
{
  "period": "month",
  "date_range": {
    "start": "2024-11-01",
    "end": "2024-11-30"
  },
  
  "total_expenses": 120000.00,
  
  "by_category": [
    {
      "category": "cerveza",
      "amount": 25000.00,
      "percentage": 20.83,
      "count": 15,
      "cost_type": "cogs"
    },
    {
      "category": "nomina",
      "amount": 25000.00,
      "percentage": 20.83,
      "count": 4,
      "cost_type": "fixed"
    },
    {
      "category": "alimentos",
      "amount": 15000.00,
      "percentage": 12.5,
      "count": 30,
      "cost_type": "cogs"
    }
    // ... más categorías
  ],
  
  "by_cost_type": {
    "cogs": {
      "amount": 45000.00,
      "percentage": 37.5,
      "description": "Costo de productos vendidos"
    },
    "fixed": {
      "amount": 50000.00,
      "percentage": 41.67,
      "description": "Costos fijos (renta, nómina, servicios)"
    },
    "variable": {
      "amount": 25000.00,
      "percentage": 20.83,
      "description": "Costos variables (mantenimiento, varios)"
    }
  },
  
  "by_payment_source": [
    {
      "source": "efectivo_boveda",
      "amount": 50000.00,
      "percentage": 41.67
    },
    {
      "source": "efectivo_caja_chica",
      "amount": 20000.00,
      "percentage": 16.67
    },
    {
      "source": "transferencia_negocio",
      "amount": 40000.00,
      "percentage": 33.33
    },
    {
      "source": "tarjeta_daniel",
      "amount": 10000.00,
      "percentage": 8.33,
      "requires_reimbursement": true
    }
  ]
}
```

---

## 🔄 Flujos de Trabajo

### Flujo 1: Registrar Cierre de Turno Diario

**Contexto:** Al final del día, David cierra la caja en Loyverse y genera un ticket. Daniel o Raúl deben registrar ese cierre en el sistema.

**Pasos:**

1. **Usuario abre formulario de cierre** en el sistema web
2. **Usuario lee el ticket de Loyverse** e ingresa:
   - Número del cierre de caja (del ticket)
   - Fecha del reporte (cuando abrió el turno)
   - Cobros en efectivo
   - Ingresos por transferencia (brutos)
   - Ingresos por tarjeta (brutos)
   - Cerrado por (nombre: David, Raúl, Daniel)
   - Pagos/Salidas (del ticket)
   - Efectivo teórico
   - Notas (opcional)

3. **Sistema hace POST a `/api/v1/turn_closures`**

4. **Backend procesa:**
   - Crea registro en `turn_closures`
   - Calcula `total_income`
   - Actualiza saldo de **Caja Chica**:
     ```
     Nuevo saldo = $1,000 (fondo) + cash_collected - payments_withdrawals
     ```
   - Actualiza saldo de **Mercado Pago**:
     ```
     Incrementa: transfer_income + card_income
     ```

5. **Frontend muestra confirmación** y actualiza dashboard

**Resultado:**
- ✅ Cierre registrado
- ✅ Saldos de cuentas actualizados automáticamente
- ✅ Se puede ver en el dashboard inmediatamente

---

### Flujo 2: Registrar Gasto

**Contexto:** Se hace una compra para el negocio (ej: cerveza, hielo, reparación).

**Caso A: Gasto con efectivo/digital del negocio**

**Pasos:**

1. **Usuario abre formulario de gastos**
2. **Usuario ingresa:**
   - Fecha del gasto
   - Monto
   - Descripción (ej: "Cerveza corona")
   - Categoría (ej: "cerveza")
   - Origen de pago (ej: "Efectivo (Bóveda)")
   - Proveedor (ej: "Central")
   - Foto del ticket (opcional)

3. **Sistema hace POST a `/api/v1/expenses`**

4. **Backend procesa:**
   - Crea registro en `expenses`
   - Identifica que payment_source = `cash_vault`
   - Descuenta automáticamente de la cuenta **Bóveda**
   - Marca `requires_reimbursement = false`

5. **Frontend muestra confirmación**

**Resultado:**
- ✅ Gasto registrado
- ✅ Saldo de Bóveda actualizado (restó el monto)
- ✅ Aparece en el dashboard y reportes

---

**Caso B: Gasto con tarjeta personal (Daniel o Raúl)**

**Pasos:**

1. **Usuario abre formulario de gastos**
2. **Usuario ingresa:**
   - Fecha del gasto
   - Monto
   - Descripción
   - Categoría
   - Origen de pago: **"Tarjeta personal Daniel"** o **"Tarjeta personal Raúl"**
   - Proveedor
   - Foto del ticket (opcional)

3. **Sistema hace POST a `/api/v1/expenses`**

4. **Backend procesa:**
   - Crea registro en `expenses`
   - Detecta payment_source = `daniel_card` o `raul_card`
   - Marca `requires_reimbursement = true`
   - **NO descuenta de ninguna cuenta** (porque no salió del negocio)

5. **Frontend muestra confirmación** y avisa que "Este gasto requiere reembolso"

**Resultado:**
- ✅ Gasto registrado
- ✅ Marcado como pendiente de reembolso
- ✅ Aparece en "Gastos pendientes de reembolsar"

---

### Flujo 3: Reembolsar a Daniel o Raúl

**Contexto:** Daniel o Raúl han hecho varios gastos con su tarjeta personal. Ahora el negocio les va a pagar.

**Pasos:**

1. **Usuario abre sección "Reembolsos pendientes"**
2. **Sistema muestra lista de gastos** con `requires_reimbursement=true` y `reimbursed=false`, agrupados por persona:
   ```
   Daniel:
   - 10/nov - $500 - Compra de insumos
   - 12/nov - $200 - Hielo y desechables
   TOTAL: $700
   
   Raúl:
   - (Sin gastos pendientes)
   TOTAL: $0
   ```

3. **Usuario selecciona los gastos a reembolsar** (puede seleccionar algunos o todos)
4. **Usuario indica:**
   - De qué cuenta se pagará (Mercado Pago o Bóveda)
   - Fecha del reembolso
   - Notas opcionales

5. **Sistema hace POST a `/api/v1/reimbursements`**
   ```json
   {
     "to_user_id": 1, // Daniel
     "expense_ids": [5, 6],
     "amount": 700.00,
     "from_account_id": 1, // Mercado Pago
     "reimbursement_date": "2024-11-15"
   }
   ```

6. **Backend procesa:**
   - Crea registro en `reimbursements`
   - Crea registros en `reimbursement_expenses` (join table)
   - Marca los expenses como `reimbursed = true`
   - Descuenta el monto de la cuenta seleccionada (Mercado Pago o Bóveda)

7. **Frontend muestra confirmación**

**Resultado:**
- ✅ Reembolso registrado
- ✅ Gastos marcados como reembolsados
- ✅ Saldo de cuenta actualizado
- ✅ Se puede ver historial de reembolsos

---

### Flujo 4: Ver Dashboard

**Contexto:** Daniel o Raúl quieren ver cómo va el negocio.

**Pasos:**

1. **Usuario ingresa al dashboard**
2. **Usuario selecciona período:**
   - Hoy
   - Esta semana
   - Este mes
   - Rango personalizado

3. **Sistema hace múltiples requests a endpoints de dashboard:**
   - `GET /api/v1/dashboard/summary?period=month`
   - `GET /api/v1/dashboard/profitability?period=month`
   - `GET /api/v1/dashboard/break_even?period=month`
   - `GET /api/v1/dashboard/cash_flow?period=month`
   - `GET /api/v1/dashboard/expense_breakdown?period=month`

4. **Backend calcula métricas en tiempo real:**
   - Suma todos los ingresos del período (de `turn_closures`)
   - Suma todos los gastos del período (de `expenses`)
   - Calcula métricas derivadas (margen, COGS%, punto de equilibrio, etc.)
   - Lee saldos actuales de `accounts`

5. **Frontend renderiza dashboard** con:
   - Tarjetas de métricas principales
   - Gráficas
   - Tablas de desglose
   - Comparativas (si se implementa)

**Resultado:**
- ✅ Usuario ve estado financiero en tiempo real
- ✅ Puede tomar decisiones basadas en datos
- ✅ Identifica problemas (ej: COGS muy alto, cash runway bajo)

---

## 📊 Métricas y Cálculos

### Service: MetricsCalculator

Esta clase se encarga de todos los cálculos financieros.

```ruby
# app/services/metrics_calculator.rb
class MetricsCalculator
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  # ==========================================
  # INGRESOS
  # ==========================================
  
  def total_income
    @total_income ||= TurnClosure
      .where(report_date: @start_date..@end_date)
      .sum('cash_collected + transfer_income + card_income')
  end
  
  def income_by_type
    {
      cash: TurnClosure.where(report_date: @start_date..@end_date).sum(:cash_collected),
      transfers: TurnClosure.where(report_date: @start_date..@end_date).sum(:transfer_income),
      cards: TurnClosure.where(report_date: @start_date..@end_date).sum(:card_income)
    }
  end

  # ==========================================
  # EGRESOS
  # ==========================================
  
  def total_expenses
    @total_expenses ||= Expense
      .where(expense_date: @start_date..@end_date)
      .sum(:amount)
  end
  
  def expenses_by_cost_type
    expenses = Expense.where(expense_date: @start_date..@end_date)
    
    {
      cogs: expenses.select { |e| e.cost_type == 'cogs' }.sum(&:amount),
      fixed: expenses.select { |e| e.cost_type == 'fixed' }.sum(&:amount),
      variable: expenses.select { |e| e.cost_type == 'variable' }.sum(&:amount)
    }
  end
  
  def cogs_total
    expenses_by_cost_type[:cogs]
  end
  
  def fixed_costs_total
    expenses_by_cost_type[:fixed]
  end
  
  def variable_costs_total
    expenses_by_cost_type[:variable]
  end
  
  def payroll_total
    Expense
      .where(expense_date: @start_date..@end_date, category: :payroll)
      .sum(:amount)
  end

  # ==========================================
  # MÉTRICA 1: UTILIDAD NETA
  # ==========================================
  
  def net_profit
    total_income - total_expenses
  end

  # ==========================================
  # MÉTRICA 2: MARGEN DE GANANCIA NETA
  # ==========================================
  
  def net_margin
    return 0 if total_income.zero?
    (net_profit / total_income) * 100
  end

  # ==========================================
  # MÉTRICA 3: COGS %
  # ==========================================
  
  def cogs_percentage
    return 0 if total_income.zero?
    (cogs_total / total_income) * 100
  end

  # ==========================================
  # MÉTRICA 4: LABOR COST %
  # ==========================================
  
  def labor_cost_percentage
    return 0 if total_income.zero?
    (payroll_total / total_income) * 100
  end

  # ==========================================
  # MÉTRICA 5: PUNTO DE EQUILIBRIO
  # ==========================================
  
  def contribution_margin_percentage
    # De cada peso vendido, cuánto queda después de pagar COGS
    100 - cogs_percentage
  end
  
  def break_even_point
    return 0 if contribution_margin_percentage.zero?
    fixed_costs_total / (contribution_margin_percentage / 100)
  end
  
  def safety_margin
    # Cuánto estás por encima del punto de equilibrio
    total_income - break_even_point
  end
  
  def days_to_break_even
    return 0 if total_income.zero? || break_even_point.zero?
    
    # Simular día por día hasta llegar al punto de equilibrio
    daily_avg = total_income / days_in_period
    (break_even_point / daily_avg).ceil
  end

  # ==========================================
  # MÉTRICA 6: CASH RUNWAY
  # ==========================================
  
  def total_cash_available
    Account.sum(:current_balance)
  end
  
  def average_daily_expenses
    return 0 if days_in_period.zero?
    total_expenses / days_in_period
  end
  
  def cash_runway_days
    return 0 if average_daily_expenses.zero?
    total_cash_available / average_daily_expenses
  end

  # ==========================================
  # UTILIDADES
  # ==========================================
  
  def days_in_period
    (@end_date - @start_date).to_i + 1
  end
  
  # Status helpers (para el frontend)
  def cogs_status
    case cogs_percentage
    when 0..30 then 'good'
    when 31..40 then 'warning'
    else 'bad'
    end
  end
  
  def cash_runway_status
    case cash_runway_days
    when 30..Float::INFINITY then 'good'
    when 15..29 then 'warning'
    else 'critical'
    end
  end
  
  def break_even_status
    total_income >= break_even_point ? 'above_break_even' : 'below_break_even'
  end
end
```

---

## 🚀 Plan de Implementación por Milestones

### MILESTONE 1 - MVP Core (2-3 semanas)

**Objetivo:** Reemplazar formularios Google y tener dashboard básico funcional.

#### Backend (Rails API)

**Semana 1: Fundación**
- [ ] Setup del proyecto Rails en modo API
- [ ] Configurar PostgreSQL
- [ ] Setup de autenticación (Devise + JWT)
- [ ] Crear modelos base:
  - [ ] User
  - [ ] Account
  - [ ] TurnClosure
  - [ ] Expense
  - [ ] Reimbursement
  - [ ] ReimbursementExpense
- [ ] Migraciones de base de datos
- [ ] Seeds para datos iniciales (cuentas, usuarios)

**Semana 2: Endpoints Core**
- [ ] Auth endpoints (login, logout, me)
- [ ] Accounts endpoints (GET, PATCH)
- [ ] TurnClosures endpoints (CRUD)
- [ ] Expenses endpoints (CRUD)
- [ ] Reimbursements endpoints (GET, POST)
- [ ] Tests básicos con RSpec

**Semana 3: Dashboard & Métricas**
- [ ] Crear `MetricsCalculator` service
- [ ] Dashboard endpoints:
  - [ ] /summary
  - [ ] /profitability
  - [ ] /break_even
  - [ ] /cash_flow
  - [ ] /expense_breakdown
- [ ] Optimizar queries (eager loading, caching)
- [ ] Documentación de API (Swagger/Postman)

#### Frontend (Nuxt.js + Nuxt UI)

**Semana 1-2: Setup & Autenticación**
- [ ] Setup proyecto Nuxt 3
- [ ] Configurar Nuxt UI
- [ ] Sistema de autenticación (JWT)
- [ ] Layout principal
- [ ] Routing

**Semana 2-3: Formularios & Dashboard**
- [ ] Formulario de cierre de turno
- [ ] Formulario de gastos
- [ ] Lista de cierres
- [ ] Lista de gastos
- [ ] Dashboard con métricas:
  - [ ] Tarjetas de resumen
  - [ ] Gráficas básicas (Chart.js o similar)
  - [ ] Tablas de desglose
- [ ] Vista de reembolsos pendientes
- [ ] Formulario de reembolso

**Entregables:**
- ✅ API REST completa documentada
- ✅ Frontend funcional con todas las vistas
- ✅ Dashboard con métricas en tiempo real
- ✅ Sistema desplegado en staging

---

### MILESTONE 2 - Inteligencia Financiera (2 semanas)

**Objetivo:** Mejorar análisis y agregar automatizaciones.

**Funcionalidades:**

1. **Dashboard Avanzado**
   - [ ] Comparativas período vs período
   - [ ] Gráficas de tendencias
   - [ ] Filtros avanzados por fecha
   - [ ] Top gastos del período
   - [ ] Exportar reportes a PDF/Excel

2. **Módulo de Deudas**
   - [ ] Modelo `Debt`
   - [ ] CRUD de deudas
   - [ ] Registro de pagos a deuda
   - [ ] Vista consolidada de deudas

3. **Comisiones Mercado Pago**
   - [ ] Configuración de comisión (% + fijo)
   - [ ] Al registrar ingreso por tarjeta:
     - Calcular comisión
     - Crear gasto automático en "Gastos financieros"
     - Actualizar Mercado Pago con monto neto

4. **Alertas básicas** (sin push notifications aún)
   - [ ] Indicadores visuales en dashboard
   - [ ] Alerta si Caja Chica < $500
   - [ ] Alerta si Cash Runway < 15 días
   - [ ] Alerta si hay reembolsos pendientes > 7 días

---

### MILESTONE 3 - Proveedores (1-2 semanas)

**Objetivo:** Optimizar compras y comparar precios.

**Funcionalidades:**

1. **Catálogo de Proveedores**
   - [ ] Modelo `Provider`
   - [ ] Modelo `ProviderProduct` (productos que vende cada proveedor con precio)
   - [ ] CRUD de proveedores
   - [ ] CRUD de productos por proveedor

2. **Registro de gastos mejorado**
   - [ ] Al seleccionar proveedor, mostrar sus productos
   - [ ] Comparar precios entre proveedores
   - [ ] Historial de compras por proveedor

3. **Reportes de compras**
   - [ ] Dashboard de proveedores
   - [ ] ¿Cuánto gastamos con cada proveedor?
   - [ ] Historial de precios de productos
   - [ ] Análisis de proveedores más económicos

---

### MILESTONE 4 - Integración Loyverse (2 semanas)

**Objetivo:** Automatizar importación de ventas y enriquecer análisis.

**Funcionalidades:**

1. **Conexión API Loyverse**
   - [ ] Autenticación con Loyverse
   - [ ] Importar cierres automáticamente
   - [ ] Sincronizar categorías de productos
   - [ ] Webhook para sincronización en tiempo real (opcional)

2. **Dashboard enriquecido**
   - [ ] Productos más vendidos
   - [ ] Ventas por categoría de producto
   - [ ] Ticket promedio
   - [ ] Análisis de horarios pico

3. **Conciliación automática**
   - [ ] Comparar cierres de Loyverse vs sistema
   - [ ] Detectar discrepancias
   - [ ] Reportes de inconsistencias

---

### MILESTONE 5 - Nómina y RRHH (1-2 semanas)

**Objetivo:** Gestión completa de empleados.

**Funcionalidades:**

1. **Módulo de Empleados**
   - [ ] Modelo `Employee`
   - [ ] CRUD de empleados
   - [ ] Registro de horas trabajadas
   - [ ] Cálculo automático de nómina

2. **Migración del módulo Vue**
   - [ ] Migrar funcionalidad de control de horas a Nuxt
   - [ ] Hora entrada/salida
   - [ ] Costo por hora
   - [ ] Cálculo automático

3. **Integración con gastos**
   - [ ] Al registrar pago de nómina, crear expense automáticamente
   - [ ] Reportes de nómina por empleado
   - [ ] Historial de pagos

---

## ❓ Preguntas y Respuestas del Negocio

Esta sección mapea las preguntas de negocio con las funcionalidades del sistema.

### ¿Cuánto vendimos hoy/esta semana/este mes? ✅
**Milestone:** 1  
**Endpoint:** `GET /api/v1/dashboard/summary?period=day|week|month`  
**Vista:** Dashboard - Tarjeta de "Ingresos Totales"

---

### ¿Cuánto dinero tenemos disponible AHORA? ✅
**Milestone:** 1  
**Endpoint:** `GET /api/v1/accounts`  
**Vista:** Dashboard - Sección "Saldos Actuales"  
**Muestra:**
- Mercado Pago
- Bóveda
- Caja Chica
- TOTAL

---

### ¿Cuánto gastamos por categoría este mes? ✅
**Milestone:** 1  
**Endpoint:** `GET /api/v1/dashboard/expense_breakdown?period=month`  
**Vista:** Dashboard - Gráfica de dona + Tabla de categorías

---

### ¿Cuánto le debemos a cada persona/institución? ⏳
**Milestone:** 2 (Módulo de Deudas)  
**Endpoint:** `GET /api/v1/debts`  
**Vista:** Página "Deudas"

---

### ¿Cuánto nos debe el negocio a Daniel y Raúl? ✅
**Milestone:** 1  
**Endpoint:** `GET /api/v1/expenses/pending_reimbursement`  
**Vista:** Página "Reembolsos Pendientes"

---

### ¿Cuál es nuestro producto más vendido? ⏳
**Milestone:** 4 (Integración Loyverse)  
**Endpoint:** `GET /api/v1/loyverse/top_products`  
**Vista:** Dashboard - Sección "Análisis de Productos"

---

### ¿Cuánto nos cuesta operar por día? ✅
**Milestone:** 1  
**Endpoint:** `GET /api/v1/dashboard/break_even`  
**Vista:** Dashboard - Tarjeta "Punto de Equilibrio"  
**Calcula:** Costos fijos + costos variables promedio por día

---

### ¿Proyección: cuándo podremos pagar deuda X? ⏳
**Milestone:** 2 (Módulo de Deudas) + Mejora en Milestone 3  
**Requiere:**
- Saldo de deuda
- Utilidad neta promedio mensual
- Proyección lineal

---

### ¿Comparación: este mes vs. mes pasado? ⏳
**Milestone:** 2 (Dashboard Avanzado)  
**Endpoint:** `GET /api/v1/dashboard/comparison?current=2024-11&previous=2024-10`  
**Vista:** Dashboard - Sección "Comparativas"  
**Muestra:**
- Ingresos: +/- %
- Gastos: +/- %
- Utilidad Neta: +/- %
- COGS %: +/- puntos

---

### ¿Alertas: si Caja Chica < $500, avisar? ⏳
**Milestone:** 2 (Alertas básicas)  
**Implementación:**
- Frontend: Indicador visual en dashboard
- Backend: Endpoint que retorna alertas activas

**Milestones futuros:** Push notifications, emails, Telegram bot

---

## 📚 Recursos Adicionales

### Documentación de APIs Externas

**Loyverse API:**
- Docs: https://developer.loyverse.com/docs/
- Autenticación: OAuth 2.0
- Endpoints principales:
  - `/receipts` - Obtener tickets de venta
  - `/items` - Obtener productos
  - `/categories` - Obtener categorías

**Mercado Pago API** (opcional):
- Docs: https://www.mercadopago.com.mx/developers
- SDK: `mercadopago` gem
- Endpoints útiles:
  - `/v1/account/balance` - Obtener saldo
  - `/v1/payments` - Listar pagos

### Librerías Sugeridas

**Backend (Rails):**
```ruby
# Gemfile
gem 'devise'           # Autenticación
gem 'jwt'              # JSON Web Tokens
gem 'bcrypt'           # Encriptación de contraseñas
gem 'rack-cors'        # CORS para API
gem 'rspec-rails'      # Tests
gem 'factory_bot_rails' # Test factories
gem 'faker'            # Datos falsos para tests
gem 'kaminari'         # Paginación
gem 'ransack'          # Filtros/búsquedas
gem 'active_model_serializers' # JSON serialization
```

**Frontend (Nuxt):**
```json
{
  "dependencies": {
    "nuxt": "^3.x",
    "@nuxt/ui": "^2.x",
    "@pinia/nuxt": "^0.5.x",      // State management
    "@vueuse/core": "^10.x",      // Utilities
    "chart.js": "^4.x",           // Gráficas
    "vue-chartjs": "^5.x",
    "dayjs": "^1.x",              // Manejo de fechas
    "@vueuse/head": "^2.x"        // SEO
  }
}
```

---

## 🎯 Criterios de Éxito

### Milestone 1 será exitoso cuando:

- [ ] Daniel y Raúl puedan registrar cierres de turno sin usar el formulario de Google
- [ ] Daniel y Raúl puedan registrar gastos sin usar el formulario de Google
- [ ] El dashboard muestre las métricas principales en tiempo real
- [ ] Los saldos de cuentas se actualicen automáticamente
- [ ] Se puedan trackear reembolsos pendientes
- [ ] La interfaz sea intuitiva para usuarios no técnicos
- [ ] El sistema esté desplegado y accesible 24/7
- [ ] Los datos sean más confiables que el Excel

### Métricas de Éxito:

- **Reducción de tiempo:** De 10 minutos a 2 minutos para registrar un cierre
- **Reducción de errores:** De ~3 errores/semana a 0 errores (por doble registro)
- **Visibilidad:** Dashboard consultado mínimo 1 vez al día
- **Adopción:** 100% de cierres y gastos registrados en el sistema (abandono total del Excel)

---

## 🔐 Consideraciones de Seguridad

1. **Autenticación:**
   - Contraseñas encriptadas con bcrypt
   - Tokens JWT con expiración
   - HTTPS obligatorio en producción

2. **Autorización:**
   - Validar que usuario esté autenticado en cada request
   - Futuro: Roles y permisos para empleados

3. **Datos sensibles:**
   - Nunca exponer passwords en logs
   - Sanitizar inputs para prevenir SQL injection
   - Validar todos los inputs en backend

4. **Backups:**
   - Backup diario de base de datos
   - Retención de 30 días mínimo
   - Plan de recuperación ante desastres

---

## 📝 Notas Finales

### Principios de Desarrollo

1. **Keep It Simple:** Si hay dos formas de hacer algo, elegir la más simple
2. **Mobile First:** El dashboard debe ser usable desde celular
3. **Performance:** Consultas optimizadas, carga rápida
4. **User Experience:** Menos clics = mejor experiencia
5. **Reliability:** El sistema debe ser más confiable que el Excel

### Convenciones de Código

**Backend (Rails):**
- Seguir guías de Ruby: https://rubystyle.guide/
- Nombres en inglés (modelos, métodos, variables)
- Tests obligatorios para lógica de negocio

**Frontend (Nuxt):**
- Composition API (setup script)
- TypeScript opcional pero recomendado
- Componentes reutilizables
- Nombres descriptivos

### Git Workflow

- `main`: Código en producción
- `develop`: Código en desarrollo
- Feature branches: `feature/nombre-funcionalidad`
- Commits descriptivos en español o inglés

### Deployment

**Sugerencia:**
- Backend: Railway o Render (free tier para empezar)
- Frontend: Vercel (free tier)
- Database: PostgreSQL incluido en Railway/Render
- Dominio: Usar dominio custom cuando estén listos

---

## 🎉 ¡Estamos listos para empezar!

Este documento es la especificación completa del proyecto Balconcito ERP. Con esta información, cualquier desarrollador (o Claude Code) puede empezar a implementar el sistema.

**Próximos pasos:**

1. Crear proyecto Rails en modo API
2. Configurar base de datos PostgreSQL
3. Implementar modelos y migraciones
4. Crear endpoints REST
5. Setup proyecto Nuxt con Nuxt UI
6. Implementar vistas y formularios
7. Conectar frontend con backend
8. Testing
9. Deploy a staging
10. Revisión con Daniel y Raúl
11. Deploy a producción
12. 🚀 ¡Lanzamiento!

---

**Versión:** 1.0  
**Fecha:** 16 de noviembre de 2024  
**Autor:** Especificación técnica para Balconcito ERP  
**Contacto:** Daniel (Co-propietario Balconcito)