module Api
  module V1
    module Dashboard
      class DebtController < BaseController
        # GET /api/v1/dashboard/debt
        def index
          # Deudas de tarjetas de crédito (MSI)
          credit_cards = CreditCard.includes(:credit_purchases).active
          total_msi_debt = credit_cards.sum(&:total_debt)
          total_msi_monthly = credit_cards.sum(&:monthly_commitment)

          # Préstamos de inversionistas/prestamistas
          loans = Loan.includes(:lender).active
          total_loans_debt = loans.sum(:remaining_balance)
          total_loans_monthly = loans.sum(&:monthly_payment)

          # Capital de socios (inversión a reembolsar)
          # Calculado desde los gastos históricos de inversión inicial
          capital_expenses = Expense.where(category: [
            :equipment, :construction_materials, :initial_inventory,
            :marketing, :office, :transportation, :others
          ])

          # Agrupar por usuario que pagó
          capital_by_partner = capital_expenses.group(:user_id).sum(:amount)

          partners_capital = User.where(id: capital_by_partner.keys).map do |user|
            amount = capital_by_partner[user.id]
            {
              partner_id: user.id,
              partner_name: user.name,
              capital_invested: amount,
              percentage: capital_expenses.sum(:amount).zero? ? 0 : ((amount / capital_expenses.sum(:amount)) * 100).round(2),
              is_repaid: false,
              relationship: 'socio'
            }
          end

          total_capital_debt = capital_by_partner.values.sum

          # TOTALES CONSOLIDADOS
          total_liabilities = total_msi_debt + total_loans_debt + total_capital_debt
          total_monthly_commitment = total_msi_monthly + total_loans_monthly

          render json: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            summary: {
              total_liabilities: total_liabilities,
              total_monthly_commitment: total_monthly_commitment,
              breakdown: {
                credit_cards_msi: {
                  total: total_msi_debt,
                  monthly_payment: total_msi_monthly,
                  percentage: (total_msi_debt / total_liabilities * 100).round(2)
                },
                loans: {
                  total: total_loans_debt,
                  monthly_payment: total_loans_monthly,
                  percentage: (total_loans_debt / total_liabilities * 100).round(2)
                },
                partners_capital: {
                  total: total_capital_debt,
                  monthly_payment: 0, # Se paga cuando el negocio genere utilidades
                  percentage: (total_capital_debt / total_liabilities * 100).round(2)
                }
              }
            },
            credit_cards: {
              total_debt: total_msi_debt,
              monthly_commitment: total_msi_monthly,
              cards_count: credit_cards.count,
              by_card: credit_cards.map { |card|
                {
                  id: card.id,
                  name: card.display_name,
                  owner: card.user.name,
                  total_debt: card.total_debt,
                  monthly_payment: card.monthly_commitment,
                  credit_utilization: card.credit_utilization_percentage,
                  active_purchases: card.active_purchases_count
                }
              }
            },
            loans: {
              total_debt: total_loans_debt,
              monthly_commitment: total_loans_monthly,
              loans_count: loans.count,
              by_lender: loans.group_by(&:lender).map { |lender, lender_loans|
                {
                  lender_id: lender.id,
                  lender_name: lender.display_name,
                  relationship: lender.relationship,
                  total_debt: lender_loans.sum(&:remaining_balance),
                  monthly_payment: lender_loans.sum(&:monthly_payment),
                  loans_count: lender_loans.count
                }
              }
            },
            partners_capital: {
              total_capital: total_capital_debt,
              partners_count: partners_capital.count,
              by_partner: partners_capital.sort_by { |p| -p[:capital_invested] }
            },
            upcoming_payments: calculate_upcoming_payments(credit_cards, loans),
            overdue_analysis: calculate_overdue(loans),
            recommendations: generate_recommendations(total_liabilities, total_monthly_commitment, total_capital_debt)
          }
        end

        # GET /api/v1/dashboard/debt/partners_capital
        def partners_capital
          # Capital de socios con detalle
          capital_expenses = Expense.includes(:user, :payment_method)
                                    .where(category: [
                                      :equipment, :construction_materials, :initial_inventory,
                                      :marketing, :office, :transportation, :others
                                    ])

          by_partner = capital_expenses.group_by(&:user).map do |user, expenses|
            total = expenses.sum(&:amount)
            by_category = expenses.group_by(&:category).transform_values { |exps| exps.sum(&:amount) }

            {
              partner_id: user.id,
              partner_name: user.name,
              partner_email: user.email,
              total_invested: total,
              percentage: (total / capital_expenses.sum(&:amount) * 100).round(2),
              expenses_count: expenses.count,
              by_category: by_category,
              first_investment_date: expenses.min_by(&:expense_date).expense_date,
              last_investment_date: expenses.max_by(&:expense_date).expense_date,
              is_repaid: false,
              relationship: 'socio'
            }
          end

          render json: {
            total_capital: capital_expenses.sum(:amount),
            total_expenses: capital_expenses.count,
            partners: by_partner.sort_by { |p| -p[:total_invested] }
          }
        end

        private

        def calculate_upcoming_payments(credit_cards, loans)
          # Próximos 5 pagos de MSI
          msi_payments = credit_cards.flat_map do |card|
            card.credit_purchases.active.map do |purchase|
              {
                type: 'msi',
                concept: purchase.concept,
                amount: purchase.monthly_payment,
                due_date: purchase.next_payment_due_date,
                source: card.display_name
              }
            end
          end.compact.select { |p| p[:due_date].present? }

          # Próximos 5 pagos de préstamos
          loan_payments = loans.map do |loan|
            {
              type: 'loan',
              concept: "Préstamo #{loan.lender.name}",
              amount: loan.monthly_payment,
              due_date: loan.next_payment_due_date,
              source: loan.lender.display_name
            }
          end.compact.select { |p| p[:due_date].present? }

          (msi_payments + loan_payments)
            .sort_by { |p| p[:due_date] }
            .first(10)
        end

        def calculate_overdue(loans)
          overdue = loans.select(&:is_overdue?)

          {
            count: overdue.count,
            total_amount: overdue.sum(&:remaining_balance),
            loans: overdue.map { |loan|
              {
                id: loan.id,
                lender: loan.lender.name,
                amount: loan.remaining_balance,
                due_date: loan.due_date,
                days_overdue: -loan.days_until_due
              }
            }
          }
        end

        def generate_recommendations(total_liabilities, total_monthly, total_capital)
          recommendations = []

          # Recomendación de flujo de caja
          if total_monthly > 0
            monthly_sales_needed = (total_monthly / 0.3).round(2) # Asumiendo 30% de margen
            recommendations << {
              type: 'cash_flow',
              priority: 'high',
              message: "Necesitas generar al menos $#{monthly_sales_needed}/mes en ventas para cubrir tus compromisos mensuales de $#{total_monthly}",
              action: 'Asegurar ventas mínimas mensuales'
            }
          end

          # Recomendación de capital de socios
          if total_capital > 100000
            recommendations << {
              type: 'partners_capital',
              priority: 'medium',
              message: "Tienes $#{total_capital} de capital de socios sin reembolsar. Considera establecer un plan de repago cuando el negocio genere utilidades.",
              action: 'Planificar repago de capital'
            }
          end

          # Recomendación de deuda total
          debt_to_capital_ratio = total_capital.zero? ? 0 : ((total_liabilities - total_capital) / total_capital * 100).round(2)
          if debt_to_capital_ratio > 50
            recommendations << {
              type: 'debt_ratio',
              priority: 'high',
              message: "Tu ratio de deuda externa vs capital es #{debt_to_capital_ratio}%. Considera reducir deuda antes de tomar más.",
              action: 'Priorizar pago de deudas'
            }
          end

          recommendations
        end
      end
    end
  end
end
