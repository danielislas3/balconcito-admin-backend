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
        by_type: income_by_type
      },
      expenses: {
        total: total_expenses,
        by_cost_type: expenses_by_cost_type,
        cogs: cogs_total,
        fixed: fixed_costs_total,
        variable: variable_costs_total,
        payroll: payroll_total
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
        runway_days: cash_runway_days,
        status: cash_runway_status
      },
      status: {
        cogs: cogs_status,
        cash_runway: cash_runway_status,
        break_even: break_even_status
      }
    }
  end
end
