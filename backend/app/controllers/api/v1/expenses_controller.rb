module Api
  module V1
    class ExpensesController < ApplicationController
      before_action :set_expense, only: [:show, :update, :destroy]

      # GET /api/v1/expenses
      def index
        expenses = Expense.all.order(expense_date: :desc)

        # Filtros opcionales
        expenses = expenses.where('expense_date >= ?', params[:date_from]) if params[:date_from]
        expenses = expenses.where('expense_date <= ?', params[:date_to]) if params[:date_to]
        expenses = expenses.where(category: params[:category]) if params[:category]
        expenses = expenses.where(payment_source: params[:payment_source]) if params[:payment_source]
        expenses = expenses.where(requires_reimbursement: params[:requires_reimbursement]) if params[:requires_reimbursement]

        render json: {
          expenses: expenses.as_json(
            only: [:id, :expense_date, :amount, :description, :category, :payment_source,
                   :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
            methods: [:cost_type]
          ),
          summary: {
            total_expenses: expenses.sum(:amount),
            count: expenses.count
          }
        }
      end

      # GET /api/v1/expenses/pending_reimbursement
      def pending_reimbursement
        expenses = Expense.pending_reimbursement.order(expense_date: :desc)

        # Agrupar por usuario (quien pagó con su tarjeta)
        grouped = expenses.group_by { |e| e.payment_source }

        result = {}
        grouped.each do |payment_source, exps|
          user_name = payment_source.include?('daniel') ? 'Daniel' : 'Raúl'
          result[user_name.downcase] = {
            expenses: exps.as_json(
              only: [:id, :expense_date, :amount, :description, :category, :payment_source,
                     :provider, :receipt_photo_url, :created_at]
            ),
            total: exps.sum(&:amount)
          }
        end

        render json: { pending_reimbursements: result }
      end

      # GET /api/v1/expenses/:id
      def show
        render json: {
          expense: @expense.as_json(
            only: [:id, :expense_date, :amount, :description, :category, :payment_source,
                   :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
            methods: [:cost_type]
          )
        }
      end

      # POST /api/v1/expenses
      def create
        expense = current_user.expenses.new(expense_params)

        if expense.save
          render json: {
            expense: expense.as_json(
              only: [:id, :expense_date, :amount, :description, :category, :payment_source,
                     :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
              methods: [:cost_type]
            ),
            message: 'Gasto registrado exitosamente'
          }, status: :created
        else
          render_error(expense.errors.full_messages.join(', '))
        end
      end

      # PATCH /api/v1/expenses/:id
      def update
        if @expense.update(expense_params)
          render json: {
            expense: @expense.as_json(
              only: [:id, :expense_date, :amount, :description, :category, :payment_source,
                     :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
              methods: [:cost_type]
            ),
            message: 'Gasto actualizado exitosamente'
          }
        else
          render_error(@expense.errors.full_messages.join(', '))
        end
      end

      # DELETE /api/v1/expenses/:id
      def destroy
        if @expense.destroy
          render json: { message: 'Gasto eliminado exitosamente' }
        else
          render_error('No se pudo eliminar el gasto')
        end
      end

      private

      def set_expense
        @expense = Expense.find(params[:id])
      end

      def expense_params
        params.require(:expense).permit(
          :expense_date, :amount, :description, :category, :payment_source,
          :provider, :receipt_photo_url
        )
      end
    end
  end
end
