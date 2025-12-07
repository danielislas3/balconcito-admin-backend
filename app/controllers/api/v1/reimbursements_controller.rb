module Api
  module V1
    class ReimbursementsController < ApplicationController
      before_action :set_reimbursement, only: [ :show ]

      # GET /api/v1/reimbursements
      def index
        reimbursements = Reimbursement.all.order(reimbursement_date: :desc).includes(:to_user, :from_account, :expenses)

        render json: {
          reimbursements: reimbursements.map do |r|
            {
              id: r.id,
              reimbursement_date: r.reimbursement_date,
              amount: r.amount,
              to_user: {
                id: r.to_user.id,
                name: r.to_user.name,
                email: r.to_user.email
              },
              from_account: {
                id: r.from_account.id,
                name: r.from_account.name,
                account_type: r.from_account.account_type
              },
              expenses_count: r.expenses.count,
              notes: r.notes,
              created_at: r.created_at
            }
          end
        }
      end

      # GET /api/v1/reimbursements/:id
      def show
        render json: {
          reimbursement: {
            id: @reimbursement.id,
            reimbursement_date: @reimbursement.reimbursement_date,
            amount: @reimbursement.amount,
            to_user: {
              id: @reimbursement.to_user.id,
              name: @reimbursement.to_user.name,
              email: @reimbursement.to_user.email
            },
            from_account: {
              id: @reimbursement.from_account.id,
              name: @reimbursement.from_account.name,
              account_type: @reimbursement.from_account.account_type
            },
            expenses: @reimbursement.expenses.as_json(
              only: [ :id, :expense_date, :amount, :description, :category, :payment_source, :provider ]
            ),
            notes: @reimbursement.notes,
            created_at: @reimbursement.created_at
          }
        }
      end

      # POST /api/v1/reimbursements
      def create
        reimbursement = current_user.reimbursements_created.new(reimbursement_params)

        # Crear las relaciones con los gastos
        if params[:expense_ids].present?
          expenses = Expense.where(id: params[:expense_ids], requires_reimbursement: true, reimbursed: false)

          if expenses.empty?
            render_error("No se encontraron gastos válidos para reembolsar")
            return
          end

          # Calcular el monto total si no se proporciona
          reimbursement.amount ||= expenses.sum(:amount)
        end

        if reimbursement.save
          # Crear las relaciones con los gastos
          if params[:expense_ids].present?
            expenses.each do |expense|
              reimbursement.reimbursement_expenses.create!(
                expense: expense,
                amount: expense.amount
              )
            end
          end

          render json: {
            reimbursement: {
              id: reimbursement.id,
              reimbursement_date: reimbursement.reimbursement_date,
              amount: reimbursement.amount,
              to_user: {
                id: reimbursement.to_user.id,
                name: reimbursement.to_user.name,
                email: reimbursement.to_user.email
              },
              from_account: {
                id: reimbursement.from_account.id,
                name: reimbursement.from_account.name,
                account_type: reimbursement.from_account.account_type
              },
              expenses: reimbursement.expenses.as_json(
                only: [ :id, :expense_date, :amount, :description, :category ]
              ),
              notes: reimbursement.notes
            },
            message: "Reembolso procesado exitosamente"
          }, status: :created
        else
          render_error(reimbursement.errors.full_messages.join(", "))
        end
      end

      private

      def set_reimbursement
        @reimbursement = Reimbursement.find(params[:id])
      end

      def reimbursement_params
        params.require(:reimbursement).permit(
          :reimbursement_date, :to_user_id, :from_account_id, :amount, :notes
        )
      end
    end
  end
end
