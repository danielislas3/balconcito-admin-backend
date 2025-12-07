module Api
  module V1
    class CreditPurchasesController < ApplicationController
      before_action :set_credit_purchase, only: [ :show, :update, :destroy, :record_payment, :mark_as_paid ]

      # GET /api/v1/credit_purchases
      def index
        @purchases = CreditPurchase.includes(:credit_card, :user, :debt_payments).order(purchase_date: :desc)

        # Filtros
        @purchases = @purchases.where(credit_card_id: params[:credit_card_id]) if params[:credit_card_id].present?
        @purchases = @purchases.where(user_id: params[:user_id]) if params[:user_id].present?
        @purchases = @purchases.active if params[:status] == "active"
        @purchases = @purchases.fully_paid if params[:status] == "paid"

        render json: @purchases.map { |purchase|
          {
            id: purchase.id,
            concept: purchase.concept,
            total_amount: purchase.total_amount,
            monthly_payment: purchase.monthly_payment,
            total_months: purchase.total_months,
            purchase_date: purchase.purchase_date,
            remaining_balance: purchase.remaining_balance,
            paid_months: purchase.paid_months,
            fully_paid: purchase.fully_paid,
            credit_card: {
              id: purchase.credit_card.id,
              name: purchase.credit_card.display_name
            },
            user: {
              id: purchase.user.id,
              name: purchase.user.name
            },
            metrics: {
              remaining_months: purchase.remaining_months,
              progress_percentage: purchase.progress_percentage,
              next_payment_due: purchase.next_payment_due_date
            },
            created_at: purchase.created_at
          }
        }
      end

      # GET /api/v1/credit_purchases/:id
      def show
        render json: {
          id: @credit_purchase.id,
          concept: @credit_purchase.concept,
          total_amount: @credit_purchase.total_amount,
          monthly_payment: @credit_purchase.monthly_payment,
          total_months: @credit_purchase.total_months,
          purchase_date: @credit_purchase.purchase_date,
          remaining_balance: @credit_purchase.remaining_balance,
          paid_months: @credit_purchase.paid_months,
          fully_paid: @credit_purchase.fully_paid,
          notes: @credit_purchase.notes,
          credit_card: {
            id: @credit_purchase.credit_card.id,
            name: @credit_purchase.credit_card.display_name,
            bank_name: @credit_purchase.credit_card.bank_name
          },
          user: {
            id: @credit_purchase.user.id,
            name: @credit_purchase.user.name,
            email: @credit_purchase.user.email
          },
          metrics: {
            remaining_months: @credit_purchase.remaining_months,
            progress_percentage: @credit_purchase.progress_percentage,
            next_payment_due: @credit_purchase.next_payment_due_date
          },
          payments: @credit_purchase.debt_payments.order(:payment_number).map { |payment|
            {
              id: payment.id,
              amount: payment.amount,
              payment_date: payment.payment_date,
              payment_number: payment.payment_number,
              notes: payment.notes
            }
          },
          created_at: @credit_purchase.created_at,
          updated_at: @credit_purchase.updated_at
        }
      end

      # POST /api/v1/credit_purchases
      def create
        @credit_purchase = CreditPurchase.new(credit_purchase_params)

        if @credit_purchase.save
          render json: {
            message: "Compra a MSI registrada exitosamente",
            credit_purchase: @credit_purchase
          }, status: :created
        else
          render json: { errors: @credit_purchase.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/credit_purchases/:id
      def update
        if @credit_purchase.update(credit_purchase_params)
          render json: {
            message: "Compra a MSI actualizada exitosamente",
            credit_purchase: @credit_purchase
          }
        else
          render json: { errors: @credit_purchase.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/credit_purchases/:id
      def destroy
        if @credit_purchase.debt_payments.exists?
          render json: {
            error: "No se puede eliminar la compra porque tiene pagos registrados"
          }, status: :unprocessable_entity
        else
          @credit_purchase.destroy
          render json: { message: "Compra a MSI eliminada exitosamente" }
        end
      end

      # POST /api/v1/credit_purchases/:id/record_payment
      def record_payment
        payment = @credit_purchase.record_payment(
          params[:amount].to_f,
          Date.parse(params[:payment_date]),
          notes: params[:notes]
        )

        if payment
          render json: {
            message: "Pago registrado exitosamente",
            payment: payment,
            updated_purchase: {
              remaining_balance: @credit_purchase.remaining_balance,
              paid_months: @credit_purchase.paid_months,
              fully_paid: @credit_purchase.fully_paid,
              progress_percentage: @credit_purchase.progress_percentage
            }
          }
        else
          render json: { error: "No se pudo registrar el pago" }, status: :unprocessable_entity
        end
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/credit_purchases/:id/mark_as_paid
      def mark_as_paid
        @credit_purchase.mark_as_paid!
        render json: {
          message: "Compra marcada como pagada exitosamente",
          credit_purchase: @credit_purchase
        }
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # GET /api/v1/credit_purchases/summary
      def summary
        purchases = CreditPurchase.includes(:credit_card).active

        total_debt = purchases.sum(:remaining_balance)
        total_monthly = purchases.sum(:monthly_payment)
        total_purchases = purchases.count

        by_card = purchases.group_by(&:credit_card).map do |card, card_purchases|
          {
            card_id: card.id,
            card_name: card.display_name,
            purchases_count: card_purchases.count,
            total_debt: card_purchases.sum(&:remaining_balance),
            monthly_payment: card_purchases.sum(&:monthly_payment)
          }
        end

        render json: {
          total_active_purchases: total_purchases,
          total_debt: total_debt,
          total_monthly_commitment: total_monthly,
          by_card: by_card,
          upcoming_payments: purchases.select { |p| p.next_payment_due_date.present? }
                                      .sort_by(&:next_payment_due_date)
                                      .first(5)
                                      .map { |p|
            {
              id: p.id,
              concept: p.concept,
              next_payment_date: p.next_payment_due_date,
              payment_amount: p.monthly_payment,
              card: p.credit_card.name
            }
          }
        }
      end

      private

      def set_credit_purchase
        @credit_purchase = CreditPurchase.find(params[:id])
      end

      def credit_purchase_params
        params.require(:credit_purchase).permit(
          :credit_card_id, :user_id, :concept, :total_amount,
          :monthly_payment, :total_months, :purchase_date, :notes
        )
      end
    end
  end
end
