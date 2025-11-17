# 🚀 Balconcito ERP - Quick Start Guide

## Para Claude Code: ¿Por dónde empezar?

Lee primero `BALCONCITO_ERP_SPEC.md` para contexto completo. Este documento es tu checklist de implementación.

---

## 📋 MILESTONE 1 - Backend Implementation Checklist

### 1. Proyecto Rails Setup

```bash
# Crear proyecto Rails API
rails new balconcito-api --api --database=postgresql --skip-test

cd balconcito-api

# Agregar gemas necesarias
```

**Gemfile a configurar:**
```ruby
gem 'devise'
gem 'devise-jwt'
gem 'jsonapi-serializer' # o active_model_serializers
gem 'rack-cors'
gem 'rspec-rails', group: [:development, :test]
gem 'factory_bot_rails', group: [:development, :test]
gem 'faker', group: [:development, :test]
```

---

### 2. Database Setup

**Orden de creación de modelos:**

#### 2.1 User Model
```bash
rails g devise User
rails g migration AddFieldsToUsers name:string role:string

# Agregar en migration:
# add_column :users, :name, :string, null: false
# add_column :users, :role, :string, default: 'admin'
```

#### 2.2 Account Model
```bash
rails g model Account name:string account_type:string current_balance:decimal description:text

# En migration, configurar:
# t.decimal :current_balance, precision: 15, scale: 2, default: 0.0
# add_index :accounts, :name, unique: true
# add_index :accounts, :account_type
```

#### 2.3 TurnClosure Model
```bash
rails g model TurnClosure closure_number:integer report_date:date cash_collected:decimal transfer_income:decimal card_income:decimal closed_by:string theoretical_cash:decimal payments_withdrawals:decimal notes:text user:references

# En migration:
# Todos los decimals: precision: 15, scale: 2, default: 0.0
# add_index :turn_closures, :closure_number, unique: true
# add_index :turn_closures, :report_date
```

#### 2.4 Expense Model
```bash
rails g model Expense expense_date:date amount:decimal description:text category:string payment_source:string provider:string receipt_photo_url:string requires_reimbursement:boolean reimbursed:boolean user:references

# En migration:
# t.decimal :amount, precision: 15, scale: 2, null: false
# t.boolean :requires_reimbursement, default: false
# t.boolean :reimbursed, default: false
# add_index :expenses, :expense_date
# add_index :expenses, :category
# add_index :expenses, [:requires_reimbursement, :reimbursed]
```

#### 2.5 Reimbursement Models
```bash
rails g model Reimbursement reimbursement_date:date to_user:references amount:decimal from_account:references notes:text user:references

rails g model ReimbursementExpense reimbursement:references expense:references amount:decimal

# En Reimbursement migration:
# t.references :to_user, foreign_key: { to_table: :users }
# t.references :from_account, foreign_key: { to_table: :accounts }
# t.decimal :amount, precision: 15, scale: 2, null: false
```

---

### 3. Models Implementation

#### Orden de implementación:

1. **User** (app/models/user.rb)
   - [x] Devise configuration
   - [ ] Validations
   - [ ] Associations

2. **Account** (app/models/account.rb)
   - [ ] Enum para account_type
   - [ ] Validations
   - [ ] Scope `total_balance`

3. **TurnClosure** (app/models/turn_closure.rb)
   - [ ] Validations
   - [ ] Association con User
   - [ ] Callback `after_create :update_account_balances`
   - [ ] Método `total_income`
   - [ ] Método privado `update_account_balances`

4. **Expense** (app/models/expense.rb)
   - [ ] Enums: `category`, `payment_source`
   - [ ] Validations
   - [ ] Associations
   - [ ] Scopes: `pending_reimbursement`, `by_date_range`
   - [ ] Callback `before_create :check_if_requires_reimbursement`
   - [ ] Callback `after_create :update_account_balance`
   - [ ] Método `cost_type`

5. **Reimbursement** (app/models/reimbursement.rb)
   - [ ] Associations
   - [ ] Validations
   - [ ] Callback `after_create :mark_expenses_as_reimbursed`
   - [ ] Callback `after_create :update_account_balance`

6. **ReimbursementExpense** (app/models/reimbursement_expense.rb)
   - [ ] Associations básicas

---

### 4. Seeds (db/seeds.rb)

```ruby
# Crear usuarios
daniel = User.create!(
  email: 'daniel@balconcito.com',
  password: 'password123',
  name: 'Daniel',
  role: 'admin'
)

raul = User.create!(
  email: 'raul@balconcito.com',
  password: 'password123',
  name: 'Raúl',
  role: 'admin'
)

# Crear cuentas
Account.create!([
  { name: 'Mercado Pago', account_type: 'digital', current_balance: 0 },
  { name: 'Bóveda', account_type: 'physical_cash', current_balance: 0 },
  { name: 'Caja Chica', account_type: 'petty_cash', current_balance: 1000 }
])

puts "✅ Seeds creados: 2 usuarios, 3 cuentas"
```

---

### 5. Controllers

#### Estructura de directorios:
```
app/
  controllers/
    api/
      v1/
        auth_controller.rb
        accounts_controller.rb
        turn_closures_controller.rb
        expenses_controller.rb
        reimbursements_controller.rb
        dashboard/
          summary_controller.rb
          profitability_controller.rb
          break_even_controller.rb
          cash_flow_controller.rb
          expense_breakdown_controller.rb
```

#### Orden de implementación:

1. **Auth** (api/v1/auth_controller.rb)
   - [ ] `POST /login`
   - [ ] `POST /logout`
   - [ ] `GET /me`

2. **Accounts** (api/v1/accounts_controller.rb)
   - [ ] `GET /accounts` (index)
   - [ ] `GET /accounts/:id` (show)
   - [ ] `PATCH /accounts/:id` (update)

3. **TurnClosures** (api/v1/turn_closures_controller.rb)
   - [ ] CRUD completo
   - [ ] Filtros: date_from, date_to, closed_by
   - [ ] Summary en index

4. **Expenses** (api/v1/expenses_controller.rb)
   - [ ] CRUD completo
   - [ ] Filtros: date_from, date_to, category, payment_source
   - [ ] `GET /pending_reimbursement` (action custom)

5. **Reimbursements** (api/v1/reimbursements_controller.rb)
   - [ ] `GET /reimbursements` (index)
   - [ ] `POST /reimbursements` (create)
   - [ ] `GET /reimbursements/:id` (show)

---

### 6. Services

#### MetricsCalculator (app/services/metrics_calculator.rb)

**Métodos a implementar:**

```ruby
class MetricsCalculator
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  # Ingresos
  def total_income                    # ✅ Implementar
  def income_by_type                  # ✅ Implementar

  # Egresos  
  def total_expenses                  # ✅ Implementar
  def expenses_by_cost_type           # ✅ Implementar
  def cogs_total                      # ✅ Implementar
  def fixed_costs_total               # ✅ Implementar
  def variable_costs_total            # ✅ Implementar
  def payroll_total                   # ✅ Implementar

  # Métricas
  def net_profit                      # ✅ Implementar
  def net_margin                      # ✅ Implementar
  def cogs_percentage                 # ✅ Implementar
  def labor_cost_percentage           # ✅ Implementar
  def contribution_margin_percentage  # ✅ Implementar
  def break_even_point                # ✅ Implementar
  def safety_margin                   # ✅ Implementar
  def days_to_break_even              # ✅ Implementar
  def total_cash_available            # ✅ Implementar
  def average_daily_expenses          # ✅ Implementar
  def cash_runway_days                # ✅ Implementar

  # Helpers
  def days_in_period                  # ✅ Implementar
  def cogs_status                     # ✅ Implementar
  def cash_runway_status              # ✅ Implementar
  def break_even_status               # ✅ Implementar
end
```

Ver `BALCONCITO_ERP_SPEC.md` sección "Métricas y Cálculos" para la implementación completa.

---

### 7. Dashboard Controllers

Cada uno usa `MetricsCalculator` internamente:

1. **SummaryController** 
   ```ruby
   GET /api/v1/dashboard/summary?period=month&date=2024-11-15
   # Retorna: income, expenses, balance, accounts, pending_reimbursements
   ```

2. **ProfitabilityController**
   ```ruby
   GET /api/v1/dashboard/profitability?period=month
   # Retorna: net_profit, net_margin, cogs_%, labor_cost_%
   ```

3. **BreakEvenController**
   ```ruby
   GET /api/v1/dashboard/break_even?period=month
   # Retorna: punto de equilibrio, margen de seguridad, días para llegar
   ```

4. **CashFlowController**
   ```ruby
   GET /api/v1/dashboard/cash_flow?period=month
   # Retorna: saldos, cash runway days, distribución gastos
   ```

5. **ExpenseBreakdownController**
   ```ruby
   GET /api/v1/dashboard/expense_breakdown?period=month
   # Retorna: gastos por categoría, por tipo de costo, por fuente de pago
   ```

---

### 8. Routes (config/routes.rb)

```ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'

      # Resources
      resources :accounts, only: [:index, :show, :update]
      resources :turn_closures
      resources :expenses do
        collection do
          get :pending_reimbursement
        end
      end
      resources :reimbursements, only: [:index, :create, :show]

      # Dashboard
      namespace :dashboard do
        get :summary
        get :profitability
        get :break_even
        get :cash_flow
        get :expense_breakdown
      end
    end
  end
end
```

---

### 9. CORS Configuration (config/initializers/cors.rb)

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', 'balconcito.vercel.app' # Agregar dominio de producción

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

---

## 🧪 Testing Strategy

### Models
- [ ] User: validations, associations
- [ ] Account: validations, scopes
- [ ] TurnClosure: validations, callbacks, calculations
- [ ] Expense: validations, callbacks, cost_type method
- [ ] Reimbursement: validations, callbacks

### Services
- [ ] MetricsCalculator: todos los métodos de cálculo

### Controllers
- [ ] Auth: login exitoso, login fallido, logout
- [ ] Accounts: index, show, update
- [ ] TurnClosures: CRUD, filtros
- [ ] Expenses: CRUD, filtros, pending_reimbursement
- [ ] Reimbursements: create, index
- [ ] Dashboard: todos los endpoints retornan formato correcto

---

## 📊 Data para Testing

### Crear datos de prueba con FactoryBot

```ruby
# spec/factories/turn_closures.rb
FactoryBot.define do
  factory :turn_closure do
    association :user
    closure_number { Faker::Number.unique.between(from: 1, to: 1000) }
    report_date { Date.today }
    cash_collected { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    transfer_income { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    card_income { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    closed_by { ['David', 'Raúl', 'Daniel'].sample }
    theoretical_cash { cash_collected + 1000 }
    payments_withdrawals { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end

# spec/factories/expenses.rb
FactoryBot.define do
  factory :expense do
    association :user
    expense_date { Date.today }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    description { Faker::Lorem.sentence }
    category { Expense.categories.keys.sample }
    payment_source { Expense.payment_sources.keys.sample }
    provider { Faker::Company.name }
  end
end
```

---

## 🚀 Deployment Checklist

### Antes de deploy:

- [ ] Variables de entorno configuradas
  - `DATABASE_URL`
  - `SECRET_KEY_BASE`
  - `JWT_SECRET_KEY`
  - `FRONTEND_URL` (para CORS)

- [ ] Seeds ejecutados
- [ ] Migraciones corridas
- [ ] Tests pasando
- [ ] Documentación de API lista (Postman/Swagger)

### Railway/Render Setup:

1. Conectar repo de GitHub
2. Configurar build command: `bundle install && rails db:migrate`
3. Configurar start command: `rails server`
4. Agregar PostgreSQL addon
5. Configurar variables de entorno
6. Deploy! 🚀

---

## 📝 Notas Importantes

### Convenciones:
- **Decimals:** Siempre `precision: 15, scale: 2`
- **Enums:** Valores en español (como los usa Daniel)
- **Dates:** Usar `Date` no `DateTime` para campos como expense_date
- **Money:** Nunca usar floats, siempre decimal
- **Callbacks:** Documentar bien qué hacen

### Orden de prioridad:
1. ✅ Models + Migrations (base de datos sólida)
2. ✅ Seeds (datos iniciales)
3. ✅ Auth (proteger endpoints)
4. ✅ CRUD básicos (turn_closures, expenses)
5. ✅ MetricsCalculator (core business logic)
6. ✅ Dashboard endpoints (lo que Daniel verá)
7. ✅ Tests
8. ✅ Deploy

### Red Flags a evitar:
- ❌ No usar callbacks que generen loops infinitos
- ❌ No hacer N+1 queries (usar `includes`)
- ❌ No exponer passwords en responses
- ❌ No permitir división por cero en cálculos
- ❌ No permitir balances negativos sin validación

---

## 🎯 Definition of Done - Milestone 1

El Milestone 1 está completo cuando:

✅ API completamente funcional  
✅ Todos los endpoints documentados  
✅ Tests con coverage > 80%  
✅ Deployed en staging  
✅ Daniel puede:
  - Registrar un cierre de turno
  - Registrar un gasto
  - Ver el dashboard con métricas
  - Ver saldos de cuentas actualizados
  - Trackear reembolsos pendientes

---

## 📚 Referencias Rápidas

**Documentación completa:** Ver `BALCONCITO_ERP_SPEC.md`

**Secciones clave:**
- Modelos detallados: Sección "Base de Datos - Modelos"
- API Endpoints: Sección "API Endpoints"
- Cálculos: Sección "Métricas y Cálculos"
- Flujos: Sección "Flujos de Trabajo"

**Comandos útiles:**
```bash
# Crear migración
rails g migration NombreDeMigracion

# Correr migraciones
rails db:migrate

# Correr seeds
rails db:seed

# Rollback última migración
rails db:rollback

# Reset completo (⚠️ borra todo)
rails db:drop db:create db:migrate db:seed

# Consola Rails
rails console

# Tests
rspec

# Server
rails server
```

---

## ✨ Tips para Claude Code

1. **Lee primero el BALCONCITO_ERP_SPEC.md completo** para entender el contexto
2. **Implementa en el orden sugerido** (no te saltes pasos)
3. **Agrega tests conforme desarrollas** (no los dejes al final)
4. **Pregunta si algo no está claro** en la spec
5. **Los callbacks son críticos** - update_account_balances debe funcionar perfecto
6. **MetricsCalculator es el corazón** - invierte tiempo en hacerlo bien
7. **Los enums están en español** porque así los usa Daniel (cerveza, nomina, etc.)
8. **Validaciones son importantes** - previene datos inconsistentes

¡Éxito con la implementación! 🚀