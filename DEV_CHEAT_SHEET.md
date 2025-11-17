# 🛠️ Balconcito ERP - Development Cheat Sheet

Comandos útiles para desarrollo rápido.

---

## 🚀 Setup Inicial

### Backend (Rails)

```bash
# Crear proyecto
rails new balconcito-api --api --database=postgresql --skip-test

cd balconcito-api

# Configurar Gemfile (agregar gems necesarias)
bundle install

# Crear base de datos
rails db:create

# Generar modelos (ver orden en QUICK_START.md)
# Ejemplo:
rails g model Account name:string account_type:string current_balance:decimal description:text

# Correr migraciones
rails db:migrate

# Poblar con datos iniciales
rails db:seed
```

### Frontend (Nuxt)

```bash
# Crear proyecto
npx nuxi init balconcito-frontend

cd balconcito-frontend

# Instalar dependencias
npm install

# Instalar Nuxt UI
npm install @nuxt/ui

# Instalar otras dependencias
npm install @pinia/nuxt chart.js vue-chartjs dayjs
```

---

## 🗄️ Database Commands

```bash
# Crear migración
rails g migration AddFieldToModel field:type

# Correr migraciones
rails db:migrate

# Rollback última migración
rails db:rollback

# Rollback N migraciones
rails db:rollback STEP=3

# Reset completo (⚠️ borra todo)
rails db:drop db:create db:migrate db:seed

# Ver status de migraciones
rails db:migrate:status

# Abrir consola de PostgreSQL
rails dbconsole
```

---

## 🏗️ Generators

### Modelos

```bash
# Modelo básico
rails g model User email:string name:string role:string

# Con referencias (foreign keys)
rails g model Expense amount:decimal user:references

# Con índices (agregar después en la migration)
# add_index :table_name, :column_name
# add_index :table_name, :column_name, unique: true
```

### Controllers

```bash
# Controller básico (API)
rails g controller Api::V1::Accounts --skip-routes --skip-helper --skip-assets

# Con actions
rails g controller Api::V1::Expenses index create update destroy --skip-routes

# Scaffold completo (no recomendado para API)
# rails g scaffold Model field:type --api
```

### Otros

```bash
# Migración standalone
rails g migration AddIndexToUsers email:uniq

# Service object (crear manualmente)
touch app/services/metrics_calculator.rb
```

---

## 🧪 Testing (RSpec)

```bash
# Setup RSpec (primera vez)
rails g rspec:install

# Generar spec para modelo
rails g rspec:model User

# Generar spec para controller
rails g rspec:controller Api::V1::Accounts

# Correr todos los tests
rspec

# Correr tests específicos
rspec spec/models/user_spec.rb
rspec spec/models/user_spec.rb:10  # Línea específica

# Correr con formato
rspec --format documentation

# Ver coverage
COVERAGE=true rspec
```

---

## 🔍 Console Commands

```bash
# Abrir consola Rails
rails console

# O abrir en ambiente específico
rails console production
rails console test
```

### Comandos útiles en consola:

```ruby
# Ver todos los modelos
ActiveRecord::Base.connection.tables

# Contar registros
User.count
Expense.count

# Crear registro
User.create!(email: 'test@test.com', name: 'Test', password: 'password123')

# Buscar
User.find(1)
User.find_by(email: 'daniel@balconcito.com')
User.where(role: 'admin')

# Actualizar
user = User.first
user.update(name: 'Nuevo Nombre')

# Eliminar
user = User.last
user.destroy

# Ver queries SQL
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Reload classes (si cambias código)
reload!

# Ver rutas
Rails.application.routes.routes.map { |r| "#{r.verb} #{r.path.spec}" }

# Calcular métricas (ejemplo)
calc = MetricsCalculator.new(Date.today.beginning_of_month, Date.today.end_of_month)
calc.net_profit
calc.net_margin
calc.break_even_point
calc.cash_runway_days
```

---

## 🚦 Server Commands

```bash
# Iniciar servidor Rails
rails server
# O
rails s

# En puerto específico
rails s -p 3001

# En ambiente específico
rails s -e production

# Ver rutas
rails routes

# Ver rutas de un controller específico
rails routes -c accounts

# Ver rutas que coincidan con patrón
rails routes -g turn_closure
```

---

## 🔐 Devise & JWT

```bash
# Instalar Devise
rails g devise:install

# Crear modelo User con Devise
rails g devise User

# Generar vistas (si necesitas)
rails g devise:views

# Generar controllers personalizados
rails g devise:controllers users

# Configurar JWT (manual en config/initializers/)
# Ver docs: https://github.com/waiting-for-dev/devise-jwt
```

---

## 📦 Bundle Commands

```bash
# Instalar gems
bundle install

# Actualizar una gem específica
bundle update rails

# Ver gems instaladas
bundle list

# Ver dónde está instalada una gem
bundle show devise

# Limpiar gems no usadas
bundle clean

# Ver gems outdated
bundle outdated
```

---

## 🎨 Frontend (Nuxt) Commands

```bash
# Dev server
npm run dev

# Build para producción
npm run build

# Preview build de producción
npm run preview

# Generate static site
npm run generate

# Lint code
npm run lint

# Lint y fix
npm run lint:fix
```

---

## 📊 Datos de Prueba

### Seeds útiles

```ruby
# db/seeds.rb

# Limpiar datos existentes
puts "🗑️  Limpiando datos..."
ReimbursementExpense.destroy_all
Reimbursement.destroy_all
Expense.destroy_all
TurnClosure.destroy_all
Account.destroy_all
User.destroy_all

# Crear usuarios
puts "👥 Creando usuarios..."
daniel = User.create!(
  email: 'daniel@balconcito.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Daniel',
  role: 'admin'
)

raul = User.create!(
  email: 'raul@balconcito.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Raúl',
  role: 'admin'
)

# Crear cuentas
puts "🏦 Creando cuentas..."
mercadopago = Account.create!(
  name: 'Mercado Pago',
  account_type: 'digital',
  current_balance: 45000.00
)

boveda = Account.create!(
  name: 'Bóveda',
  account_type: 'physical_cash',
  current_balance: 20000.00
)

caja_chica = Account.create!(
  name: 'Caja Chica',
  account_type: 'petty_cash',
  current_balance: 3000.00
)

# Crear cierres de turno (últimos 7 días)
puts "📝 Creando cierres de turno..."
7.times do |i|
  TurnClosure.create!(
    user: [daniel, raul].sample,
    closure_number: 50 + i,
    report_date: Date.today - (6 - i).days,
    cash_collected: rand(3000..8000).to_f,
    transfer_income: rand(500..2000).to_f,
    card_income: rand(1000..3000).to_f,
    closed_by: ['David', 'Raúl', 'Daniel'].sample,
    theoretical_cash: 0, # Se calculará
    payments_withdrawals: rand(0..200).to_f
  )
end

# Crear gastos variados
puts "💸 Creando gastos..."
categories = Expense.categories.keys
sources = Expense.payment_sources.keys

30.times do
  Expense.create!(
    user: [daniel, raul].sample,
    expense_date: Date.today - rand(0..30).days,
    amount: rand(50..5000).to_f,
    description: ['Cerveza Corona', 'Hielo', 'Papas', 'Limpieza', 'Gas', 'Agua'].sample,
    category: categories.sample,
    payment_source: sources.sample,
    provider: ['Central', 'La Manita', 'BBB', 'El Cotee'].sample
  )
end

puts "✅ Seeds completados!"
puts "   - #{User.count} usuarios"
puts "   - #{Account.count} cuentas"
puts "   - #{TurnClosure.count} cierres"
puts "   - #{Expense.count} gastos"
```

---

## 🔧 Debugging

### Rails

```ruby
# En cualquier parte del código
debugger  # Si usas gem 'debug'
binding.pry  # Si usas gem 'pry-rails'

# Ver variables
puts variable.inspect
pp variable  # Pretty print

# Ver stack trace
caller

# Benchmark
Benchmark.measure { your_code_here }
```

### Logs

```bash
# Ver logs en tiempo real
tail -f log/development.log

# Ver últimas líneas
tail -n 100 log/development.log

# Buscar en logs
grep "ERROR" log/development.log

# Limpiar logs
> log/development.log
```

---

## 🚀 Deployment

### Railway

```bash
# Instalar CLI
npm install -g @railway/cli

# Login
railway login

# Inicializar proyecto
railway init

# Deploy
railway up

# Ver logs
railway logs

# Abrir en browser
railway open
```

### Render

```bash
# No requiere CLI, se hace desde dashboard web
# 1. Conectar repo GitHub
# 2. Configurar build: bundle install && rails db:migrate
# 3. Configurar start: rails server
# 4. Agregar PostgreSQL addon
# 5. Deploy
```

### Variables de entorno

```bash
# Producción
DATABASE_URL=postgresql://...
SECRET_KEY_BASE=...
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
FRONTEND_URL=https://balconcito.vercel.app

# Generar secret key base
rails secret
```

---

## 📝 Useful Snippets

### Controller básico

```ruby
# app/controllers/api/v1/accounts_controller.rb
module Api
  module V1
    class AccountsController < ApplicationController
      before_action :authenticate_user!
      
      def index
        accounts = Account.all
        render json: {
          accounts: accounts,
          total_balance: accounts.sum(:current_balance)
        }
      end
      
      def show
        account = Account.find(params[:id])
        render json: { account: account }
      end
      
      def update
        account = Account.find(params[:id])
        
        if account.update(account_params)
          render json: { account: account, message: 'Cuenta actualizada' }
        else
          render json: { errors: account.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def account_params
        params.require(:account).permit(:current_balance, :description)
      end
    end
  end
end
```

### Model con validaciones

```ruby
# app/models/expense.rb
class Expense < ApplicationRecord
  belongs_to :user
  
  # Enums
  enum category: {
    beer: 'cerveza',
    food: 'alimentos',
    # ...
  }
  
  enum payment_source: {
    cash_petty: 'efectivo_caja_chica',
    # ...
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
    when :beer, :food then 'cogs'
    when :rent, :payroll then 'fixed'
    else 'variable'
    end
  end
  
  private
  
  def check_if_requires_reimbursement
    self.requires_reimbursement = daniel_card? || raul_card?
  end
  
  def update_account_balance
    return if requires_reimbursement
    
    account = case payment_source.to_sym
              when :cash_petty then Account.find_by(account_type: 'petty_cash')
              when :cash_vault then Account.find_by(account_type: 'physical_cash')
              end
    
    account&.decrement!(:current_balance, amount)
  end
end
```

---

## 🎯 Common Issues & Solutions

### Issue: Migraciones pendientes

```bash
# Error: Migrations are pending
rails db:migrate
```

### Issue: Puerto ocupado

```bash
# Error: Address already in use - bind(2)
kill -9 $(lsof -ti:3000)
# O cambiar puerto
rails s -p 3001
```

### Issue: Bundler version mismatch

```bash
# Error: wrong bundler version
gem install bundler:2.x.x
bundle install
```

### Issue: PostgreSQL no corre

```bash
# macOS
brew services start postgresql@14

# Linux
sudo service postgresql start

# Ver status
brew services list  # macOS
sudo service postgresql status  # Linux
```

### Issue: Seeds fallan

```bash
# Ver error detallado
rails db:seed:replant RAILS_ENV=development

# O correr en consola para ver stack trace
rails console
load 'db/seeds.rb'
```

---

## 📚 Quick Reference

### HTTP Status Codes

```
200 OK - Éxito
201 Created - Recurso creado
204 No Content - Éxito sin contenido
400 Bad Request - Error en request
401 Unauthorized - No autenticado
403 Forbidden - No autorizado
404 Not Found - No encontrado
422 Unprocessable Entity - Validación fallida
500 Internal Server Error - Error del servidor
```

### Rails Environments

```
development - Local development
test - Para correr tests
production - Producción
```

### ActiveRecord Queries

```ruby
# Búsqueda
Model.find(id)
Model.find_by(field: value)
Model.where(field: value)
Model.where.not(field: value)
Model.where("created_at > ?", 1.week.ago)

# Ordenamiento
Model.order(created_at: :desc)
Model.order("amount DESC")

# Límite
Model.limit(10)
Model.first(5)
Model.last(5)

# Agregaciones
Model.count
Model.sum(:amount)
Model.average(:amount)
Model.maximum(:amount)
Model.minimum(:amount)

# Joins
Model.joins(:association)
Model.includes(:association)  # Evita N+1

# Agrupamiento
Model.group(:category).count
Model.group(:category).sum(:amount)
```

---

¡Guarda este archivo para referencia rápida durante desarrollo! 🚀