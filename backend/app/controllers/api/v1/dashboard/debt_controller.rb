module Api
  module V1
    module Dashboard
      class DebtController < BaseController
        # GET /api/v1/dashboard/debt
        # Retorna resumen unificado de todas las deudas del negocio
        def index
          render json: {
            summary: debt_summary,
            credit_cards: credit_cards_debt,
            loans: loans_debt,
            partners_capital: partners_capital_debt,
            total_liabilities: total_liabilities,
            monthly_commitments: monthly_commitments
          }
        end

        private

        def debt_summary
          {
            total_msi_debt: total_msi_debt,
            total_loans_debt: total_loans_debt,
            total_capital_debt: total_capital_debt,
            total_all_debt: total_liabilities,
            debt_breakdown: {
              msi_percentage: percentage_of_total(total_msi_debt),
              loans_percentage: percentage_of_total(total_loans_debt),
              capital_percentage: percentage_of_total(total_capital_debt)
            }
          }
        end

        def credit_cards_debt
          CreditCard.includes(:credit_purchases).map do |card|
            {
              id: card.id,
              card_name: card.card_name,
              bank: card.bank,
              total_limit: card.total_limit,
              total_debt: card.total_debt,
              monthly_commitment: card.monthly_commitment,
              available_credit: card.available_credit,
              utilization_percentage: (card.total_debt / card.total_limit * 100).round(2),
              active_purchases_count: card.credit_purchases.where(fully_paid: false).count
            }
          end
        end

        def loans_debt
          Loan.includes(:lender).where(is_paid: false).map do |loan|
            {
              id: loan.id,
              lender_name: loan.lender.name,
              lender_relationship: loan.lender.relationship,
              principal_amount: loan.principal_amount,
              remaining_balance: loan.remaining_balance,
              monthly_payment: loan.monthly_payment,
              interest_rate: loan.interest_rate,
              term_months: loan.term_months,
              paid_months: loan.paid_months,
              completion_percentage: (loan.paid_months.to_f / loan.term_months * 100).round(2)
            }
          end
        end

        def partners_capital_debt
          # Capital de socios = Gastos CAPEX agrupados por usuario
          capital_by_partner = Expense.where(category: [
            :equipment, :construction_materials, :initial_inventory,
            :marketing, :office, :transportation, :others
          ]).group(:user_id).sum(:amount)

          capital_by_partner.map do |user_id, amount|
            user = User.find(user_id)
            {
              user_id: user.id,
              user_name: user.name,
              email: user.email,
              capital_invested: amount,
              percentage_of_total: percentage_of_total(amount)
            }
          end
        end

        def total_msi_debt
          @total_msi_debt ||= CreditCard.sum { |card| card.total_debt }
        end

        def total_loans_debt
          @total_loans_debt ||= Loan.where(is_paid: false).sum(:remaining_balance)
        end

        def total_capital_debt
          @total_capital_debt ||= Expense.where(category: [
            :equipment, :construction_materials, :initial_inventory,
            :marketing, :office, :transportation, :others
          ]).sum(:amount)
        end

        def total_liabilities
          total_msi_debt + total_loans_debt + total_capital_debt
        end

        def monthly_commitments
          {
            msi_payments: CreditCard.sum { |card| card.monthly_commitment },
            loan_payments: Loan.where(is_paid: false).sum { |loan| loan.monthly_payment },
            total_monthly: CreditCard.sum { |card| card.monthly_commitment } +
                          Loan.where(is_paid: false).sum { |loan| loan.monthly_payment }
          }
        end

        def percentage_of_total(amount)
          return 0 if total_liabilities.zero?
          (amount / total_liabilities * 100).round(2)
        end
      end
    end
  end
end
