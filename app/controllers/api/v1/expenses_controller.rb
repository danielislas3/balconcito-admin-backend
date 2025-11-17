module Api
  module V1
    class ExpensesController < ApplicationController
      before_action :set_expense, only: [:show, :update, :destroy]

      # GET /api/v1/expenses
      def index
        expenses = Expense.includes(:payment_method).all.order(expense_date: :desc)

        # Filtros opcionales
        expenses = expenses.where('expense_date >= ?', params[:date_from]) if params[:date_from]
        expenses = expenses.where('expense_date <= ?', params[:date_to]) if params[:date_to]
        expenses = expenses.where(category: params[:category]) if params[:category]
        expenses = expenses.where(payment_method_id: params[:payment_method_id]) if params[:payment_method_id]
        expenses = expenses.where(requires_reimbursement: params[:requires_reimbursement]) if params[:requires_reimbursement]

        render json: {
          expenses: expenses.as_json(
            only: [:id, :expense_date, :amount, :description, :category, :payment_method_id,
                   :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
            include: { payment_method: { only: [:id, :name, :payment_type] } },
            methods: [:cost_type, :payment_source_name]
          ),
          summary: {
            total_expenses: expenses.sum(:amount),
            count: expenses.count
          }
        }
      end

      # GET /api/v1/expenses/pending_reimbursement
      def pending_reimbursement
        expenses = Expense.includes(:payment_method, :user).pending_reimbursement.order(expense_date: :desc)

        # Agrupar por usuario (quien pagó con su método de pago)
        grouped = expenses.group_by { |e| e.paid_by_user }

        result = {}
        grouped.each do |user, exps|
          result[user.id] = {
            user: { id: user.id, name: user.name, email: user.email },
            expenses: exps.as_json(
              only: [:id, :expense_date, :amount, :description, :category, :payment_method_id,
                     :provider, :receipt_photo_url, :created_at],
              include: { payment_method: { only: [:id, :name, :payment_type] } },
              methods: [:payment_source_name]
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
            only: [:id, :expense_date, :amount, :description, :category, :payment_method_id,
                   :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
            include: { payment_method: { only: [:id, :name, :payment_type] } },
            methods: [:cost_type, :payment_source_name]
          )
        }
      end

      # POST /api/v1/expenses
      def create
        expense = current_user.expenses.new(expense_params)

        if expense.save
          render json: {
            expense: expense.as_json(
              only: [:id, :expense_date, :amount, :description, :category, :payment_method_id,
                     :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
              include: { payment_method: { only: [:id, :name, :payment_type] } },
              methods: [:cost_type, :payment_source_name]
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
              only: [:id, :expense_date, :amount, :description, :category, :payment_method_id,
                     :provider, :receipt_photo_url, :requires_reimbursement, :reimbursed, :created_at],
              include: { payment_method: { only: [:id, :name, :payment_type] } },
              methods: [:cost_type, :payment_source_name]
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
          :expense_date, :amount, :description, :category, :payment_method_id,
          :provider, :receipt_photo_url
        )
      end
    end
  end
end
