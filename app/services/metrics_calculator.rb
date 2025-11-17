class MetricsCalculator
  def initialize(start_date, end_date)
    @start_date = start_date.to_date
    @end_date = end_date.to_date
  end

  # ==================== INGRESOS ====================

  def total_income
    TurnClosure.by_date_range(@start_date, @end_date).sum do |tc|
      tc.total_income
    end
  end

  def income_by_type
    closures = TurnClosure.by_date_range(@start_date, @end_date)
    {
      cash: closures.sum(:cash_collected),
      transfers: closures.sum(:transfer_income),
      cards: closures.sum(:card_income)
    }
  end

  # ==================== EGRESOS ====================

  def total_expenses
    Expense.by_date_range(@start_date, @end_date).sum(:amount)
  end

  def expenses_by_cost_type
    expenses = Expense.by_date_range(@start_date, @end_date)
    result = { cogs: 0, fixed: 0, variable: 0 }

    expenses.each do |expense|
      result[expense.cost_type.to_sym] += expense.amount
    end

    result
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
    Expense.by_date_range(@start_date, @end_date)
           .where(category: 'nomina')
           .sum(:amount)
  end

  # Gastos agrupados por categoría
  def expenses_by_category
    Expense.by_date_range(@start_date, @end_date)
           .group(:category)
           .sum(:amount)
           .transform_keys(&:to_s)
           .sort_by { |_k, v| -v }
           .to_h
  end

  # Gastos agrupados por método de pago
  def expenses_by_payment_source
    expenses = Expense.includes(:payment_method).by_date_range(@start_date, @end_date)

    result = Hash.new(0)
    expenses.each do |expense|
      source = expense.payment_method&.name || 'No especificado'
      result[source] += expense.amount
    end

    result.sort_by { |_k, v| -v }.to_h
  end

  # Top N gastos más altos
  def top_expenses(limit = 10)
    Expense.by_date_range(@start_date, @end_date)
           .order(amount: :desc)
           .limit(limit)
           .map do |expense|
             {
               id: expense.id,
               date: expense.expense_date,
               description: expense.description,
               amount: expense.amount,
               category: expense.category,
               payment_source: expense.payment_source_name
             }
           end
  end

  # Porcentaje de costos fijos
  def fixed_costs_percentage
    return 0 if total_expenses.zero?
    ((fixed_costs_total / total_expenses) * 100).round(2)
  end

  # Porcentaje de costos variables
  def variable_costs_percentage
    return 0 if total_expenses.zero?
    ((variable_costs_total / total_expenses) * 100).round(2)
  end

  # ==================== MÉTRICAS DE RENTABILIDAD ====================

  # Utilidad Neta = Ingresos - Gastos
  def net_profit
    total_income - total_expenses
  end

  # Margen Neto % = (Utilidad Neta / Ingresos) × 100
  def net_margin
    return 0 if total_income.zero?
    ((net_profit / total_income) * 100).round(2)
  end

  # COGS % = (COGS / Ingresos) × 100
  def cogs_percentage
    return 0 if total_income.zero?
    ((cogs_total / total_income) * 100).round(2)
  end

  # Labor Cost % = (Nómina / Ingresos) × 100
  def labor_cost_percentage
    return 0 if total_income.zero?
    ((payroll_total / total_income) * 100).round(2)
  end

  # Margen de Contribución % = 100 - COGS%
  def contribution_margin_percentage
    (100 - cogs_percentage).round(2)
  end

  # ==================== MÉTRICAS DE PUNTO DE EQUILIBRIO ====================

  # Punto de Equilibrio = Costos Fijos / (Margen de Contribución % / 100)
  def break_even_point
    return 0 if contribution_margin_percentage.zero?
    (fixed_costs_total / (contribution_margin_percentage / 100)).round(2)
  end

  # Margen de Seguridad = Ingresos - Punto de Equilibrio
  def safety_margin
    (total_income - break_even_point).round(2)
  end

  # Días para llegar al punto de equilibrio
  def days_to_break_even
    return 0 if total_income.zero?
    daily_income = total_income / days_in_period
    return 0 if daily_income.zero?
    (break_even_point / daily_income).ceil
  end

  # ==================== MÉTRICAS DE FLUJO DE EFECTIVO ====================

  # Total de efectivo disponible en todas las cuentas
  def total_cash_available
    Account.sum(:current_balance)
  end

  # Promedio de gastos diarios en el período
  def average_daily_expenses
    return 0 if days_in_period.zero?
    (total_expenses / days_in_period).round(2)
  end

  # Cash Runway = Efectivo Total / Promedio Gastos Diarios
  def cash_runway_days
    return 0 if average_daily_expenses.zero?
    (total_cash_available / average_daily_expenses).round(0)
  end

  # Promedio de ingresos diarios en el período
  def average_daily_income
    return 0 if days_in_period.zero?
    (total_income / days_in_period).round(2)
  end

  # Flujo de efectivo neto diario = Ingresos diarios - Gastos diarios
  def net_daily_cash_flow
    average_daily_income - average_daily_expenses
  end

  # Status del flujo de efectivo
  def cash_flow_status
    flow = net_daily_cash_flow
    return 'critico' if flow < -1000
    return 'negativo' if flow < 0
    return 'equilibrado' if flow < 500
    return 'positivo' if flow < 2000
    'excelente'
  end

  # ==================== MÉTRICAS DE DEUDA ====================

  # Total de deuda en tarjetas de crédito (MSI)
  def total_credit_card_debt
    CreditCard.active.sum(&:total_debt)
  end

  # Total de préstamos activos
  def total_loans_debt
    Loan.active.sum(:remaining_balance)
  end

  # Total de pasivos (tarjetas + préstamos + capital socios)
  def total_liabilities
    # Capital de socios desde gastos de inversión
    capital_expenses = Expense.where(category: [
      :equipment, :construction_materials, :initial_inventory,
      :marketing, :office, :transportation, :others
    ]).sum(:amount)

    total_credit_card_debt + total_loans_debt + capital_expenses
  end

  # Compromiso mensual total (MSI + Préstamos)
  def monthly_debt_commitment
    msi_monthly = CreditCard.active.sum(&:monthly_commitment)
    loans_monthly = Loan.active.sum(&:monthly_payment)
    msi_monthly + loans_monthly
  end

  # Ratio de deuda sobre ingresos
  def debt_to_income_ratio
    return 0 if total_income.zero?
    ((monthly_debt_commitment / (total_income / days_in_period * 30)) * 100).round(2)
  end

  # ==================== HELPERS ====================

  def days_in_period
    (@end_date - @start_date).to_i + 1
  end

  # Status del COGS (bueno, aceptable, alto)
  def cogs_status
    percentage = cogs_percentage
    return 'excelente' if percentage < 25
    return 'bueno' if percentage < 30
    return 'aceptable' if percentage < 35
    'alto'
  end

  # Status del Cash Runway
  def cash_runway_status
    days = cash_runway_days
    return 'critico' if days < 15
    return 'precaucion' if days < 30
    return 'saludable' if days < 60
    'excelente'
  end

  # Status del Punto de Equilibrio
  def break_even_status
    margin = safety_margin
    return 'perdiendo' if margin.negative?
    return 'equilibrio' if margin < 1000
    return 'rentable' if margin < 10000
    'muy_rentable'
  end

  # ==================== MÉTODO PRINCIPAL ====================

  def calculate_all
    {
      period: {
        start_date: @start_date,
        end_date: @end_date,
        days: days_in_period
      },
      income: {
        total: total_income,
        by_type: income_by_type,
        average_daily: average_daily_income
      },
      expenses: {
        total: total_expenses,
        by_cost_type: expenses_by_cost_type,
        by_category: expenses_by_category,
        by_payment_source: expenses_by_payment_source,
        cogs: cogs_total,
        fixed: fixed_costs_total,
        variable: variable_costs_total,
        payroll: payroll_total,
        fixed_percentage: fixed_costs_percentage,
        variable_percentage: variable_costs_percentage,
        average_daily: average_daily_expenses,
        top_expenses: top_expenses(10)
      },
      profitability: {
        net_profit: net_profit,
        net_margin: net_margin,
        cogs_percentage: cogs_percentage,
        labor_cost_percentage: labor_cost_percentage,
        contribution_margin: contribution_margin_percentage
      },
      break_even: {
        point: break_even_point,
        safety_margin: safety_margin,
        days_to_reach: days_to_break_even,
        status: break_even_status
      },
      cash_flow: {
        total_available: total_cash_available,
        average_daily_expenses: average_daily_expenses,
        average_daily_income: average_daily_income,
        net_daily_flow: net_daily_cash_flow,
        runway_days: cash_runway_days,
        status: cash_flow_status
      },
      debt: {
        total_liabilities: total_liabilities,
        credit_card_debt: total_credit_card_debt,
        loans_debt: total_loans_debt,
        monthly_commitment: monthly_debt_commitment,
        debt_to_income_ratio: debt_to_income_ratio
      },
      status: {
        cogs: cogs_status,
        cash_runway: cash_runway_status,
        cash_flow: cash_flow_status,
        break_even: break_even_status
      }
    }
  end
end
