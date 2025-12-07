module Api
  module V1
    class LoansController < ApplicationController
      before_action :set_loan, only: [ :show, :update, :destroy, :record_payment, :mark_as_paid ]

      # GET /api/v1/loans
      def index
        @loans = Loan.includes(:lender, :loan_payments).order(loan_date: :desc)

        # Filtros
        @loans = @loans.where(lender_id: params[:lender_id]) if params[:lender_id].present?
        @loans = @loans.active if params[:status] == "active"
        @loans = @loans.paid if params[:status] == "paid"
        @loans = @loans.with_interest if params[:with_interest] == "true"
        @loans = @loans.interest_free if params[:interest_free] == "true"

        render json: @loans.map { |loan|
          {
            id: loan.id,
            principal_amount: loan.principal_amount,
            interest_rate: loan.interest_rate,
            term_months: loan.term_months,
            loan_date: loan.loan_date,
            due_date: loan.due_date,
            remaining_balance: loan.remaining_balance,
            is_paid: loan.is_paid,
            lender: {
              id: loan.lender.id,
              name: loan.lender.display_name,
              relationship: loan.lender.relationship
            },
            metrics: {
              monthly_payment: loan.monthly_payment,
              total_interest: loan.total_interest,
              progress_percentage: loan.progress_percentage,
              payments_made: loan.payments_made_count,
              payments_remaining: loan.payments_remaining,
              days_until_due: loan.days_until_due,
              is_overdue: loan.is_overdue?
            },
            created_at: loan.created_at
          }
        }
      end

      # GET /api/v1/loans/:id
      def show
        render json: {
          id: @loan.id,
          principal_amount: @loan.principal_amount,
          interest_rate: @loan.interest_rate,
          term_months: @loan.term_months,
          loan_date: @loan.loan_date,
          due_date: @loan.due_date,
          remaining_balance: @loan.remaining_balance,
          is_paid: @loan.is_paid,
          notes: @loan.notes,
          lender: {
            id: @loan.lender.id,
            name: @loan.lender.name,
            display_name: @loan.lender.display_name,
            relationship: @loan.lender.relationship,
            contact_info: @loan.lender.contact_info
          },
          metrics: {
            monthly_payment: @loan.monthly_payment,
            total_amount_with_interest: @loan.total_amount_with_interest,
            total_interest: @loan.total_interest,
            progress_percentage: @loan.progress_percentage,
            payments_made: @loan.payments_made_count,
            payments_remaining: @loan.payments_remaining,
            next_payment_due: @loan.next_payment_due_date,
            days_until_due: @loan.days_until_due,
            is_overdue: @loan.is_overdue?
          },
          payments: @loan.loan_payments.order(:payment_number).map { |payment|
            {
              id: payment.id,
              amount: payment.amount,
              payment_date: payment.payment_date,
              payment_number: payment.payment_number,
              notes: payment.notes
            }
          },
          created_at: @loan.created_at,
          updated_at: @loan.updated_at
        }
      end

      # POST /api/v1/loans
      def create
        @loan = Loan.new(loan_params)

        if @loan.save
          render json: {
            message: "Préstamo creado exitosamente",
            loan: @loan
          }, status: :created
        else
          render json: { errors: @loan.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/loans/:id
      def update
        if @loan.update(loan_params)
          render json: {
            message: "Préstamo actualizado exitosamente",
            loan: @loan
          }
        else
          render json: { errors: @loan.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/loans/:id
      def destroy
        if @loan.loan_payments.exists?
          render json: {
            error: "No se puede eliminar el préstamo porque tiene pagos registrados"
          }, status: :unprocessable_entity
        else
          @loan.destroy
          render json: { message: "Préstamo eliminado exitosamente" }
        end
      end

      # POST /api/v1/loans/:id/record_payment
      def record_payment
        payment = @loan.record_payment(
          params[:amount].to_f,
          Date.parse(params[:payment_date]),
          notes: params[:notes]
        )

        if payment
          render json: {
            message: "Pago registrado exitosamente",
            payment: payment,
            updated_loan: {
              remaining_balance: @loan.remaining_balance,
              is_paid: @loan.is_paid,
              progress_percentage: @loan.progress_percentage,
              payments_remaining: @loan.payments_remaining
            }
          }
        else
          render json: { error: "No se pudo registrar el pago" }, status: :unprocessable_entity
        end
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/loans/:id/mark_as_paid
      def mark_as_paid
        @loan.mark_as_paid!
        render json: {
          message: "Préstamo marcado como pagado exitosamente",
          loan: @loan
        }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/loans/summary
      def summary
        loans = Loan.includes(:lender).active

        total_debt = loans.sum(:remaining_balance)
        total_principal = loans.sum(:principal_amount)
        total_monthly = loans.sum(&:monthly_payment)
        total_with_interest = loans.sum(&:total_amount_with_interest)

        by_lender = loans.group_by(&:lender).map do |lender, lender_loans|
          {
            lender_id: lender.id,
            lender_name: lender.display_name,
            relationship: lender.relationship,
            loans_count: lender_loans.count,
            total_debt: lender_loans.sum(&:remaining_balance),
            monthly_payment: lender_loans.sum(&:monthly_payment)
          }
        end

        overdue_loans = loans.select(&:is_overdue?)

        render json: {
          total_active_loans: loans.count,
          total_principal: total_principal,
          total_outstanding: total_debt,
          total_monthly_commitment: total_monthly,
          total_interest: total_with_interest - total_principal,
          by_lender: by_lender,
          overdue_loans: overdue_loans.map { |loan|
            {
              id: loan.id,
              lender: loan.lender.name,
              amount: loan.remaining_balance,
              due_date: loan.due_date,
              days_overdue: -loan.days_until_due
            }
          },
          upcoming_payments: loans.reject(&:is_paid?)
                                  .select { |l| l.next_payment_due_date.present? }
                                  .sort_by(&:next_payment_due_date)
                                  .first(5)
                                  .map { |loan|
            {
              id: loan.id,
              lender: loan.lender.name,
              next_payment_date: loan.next_payment_due_date,
              payment_amount: loan.monthly_payment
            }
          }
        }
      end

      private

      def set_loan
        @loan = Loan.find(params[:id])
      end

      def loan_params
        params.require(:loan).permit(
          :lender_id, :principal_amount, :interest_rate, :term_months,
          :loan_date, :notes
        )
      end
    end
  end
end
