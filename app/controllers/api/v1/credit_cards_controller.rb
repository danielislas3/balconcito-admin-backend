module Api
  module V1
    class CreditCardsController < ApplicationController
      before_action :set_credit_card, only: [:show, :update, :destroy]

      # GET /api/v1/credit_cards
      def index
        @credit_cards = CreditCard.includes(:user, :credit_purchases).order(created_at: :desc)

        # Filtros
        @credit_cards = @credit_cards.where(user_id: params[:user_id]) if params[:user_id].present?
        @credit_cards = @credit_cards.active if params[:active] == 'true'

        render json: @credit_cards.map { |card|
          {
            id: card.id,
            name: card.name,
            bank_name: card.bank_name,
            cut_day: card.cut_day,
            credit_limit: card.credit_limit,
            statement_day: card.statement_day,
            is_active: card.is_active,
            notes: card.notes,
            user: {
              id: card.user.id,
              name: card.user.name,
              email: card.user.email
            },
            metrics: {
              total_debt: card.total_debt,
              monthly_commitment: card.monthly_commitment,
              available_credit: card.available_credit,
              credit_utilization: card.credit_utilization_percentage,
              active_purchases: card.active_purchases_count
            },
            created_at: card.created_at,
            updated_at: card.updated_at
          }
        }
      end

      # GET /api/v1/credit_cards/:id
      def show
        render json: {
          id: @credit_card.id,
          name: @credit_card.name,
          bank_name: @credit_card.bank_name,
          cut_day: @credit_card.cut_day,
          credit_limit: @credit_card.credit_limit,
          statement_day: @credit_card.statement_day,
          is_active: @credit_card.is_active,
          notes: @credit_card.notes,
          user: {
            id: @credit_card.user.id,
            name: @credit_card.user.name,
            email: @credit_card.user.email
          },
          metrics: {
            total_debt: @credit_card.total_debt,
            monthly_commitment: @credit_card.monthly_commitment,
            available_credit: @credit_card.available_credit,
            credit_utilization: @credit_card.credit_utilization_percentage,
            active_purchases: @credit_card.active_purchases_count
          },
          credit_purchases: @credit_card.credit_purchases.order(purchase_date: :desc).map { |purchase|
            {
              id: purchase.id,
              concept: purchase.concept,
              total_amount: purchase.total_amount,
              monthly_payment: purchase.monthly_payment,
              total_months: purchase.total_months,
              paid_months: purchase.paid_months,
              remaining_balance: purchase.remaining_balance,
              fully_paid: purchase.fully_paid,
              progress_percentage: purchase.progress_percentage
            }
          },
          created_at: @credit_card.created_at,
          updated_at: @credit_card.updated_at
        }
      end

      # POST /api/v1/credit_cards
      def create
        @credit_card = CreditCard.new(credit_card_params)

        if @credit_card.save
          render json: {
            message: 'Tarjeta de crédito creada exitosamente',
            credit_card: @credit_card
          }, status: :created
        else
          render json: { errors: @credit_card.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/credit_cards/:id
      def update
        if @credit_card.update(credit_card_params)
          render json: {
            message: 'Tarjeta de crédito actualizada exitosamente',
            credit_card: @credit_card
          }
        else
          render json: { errors: @credit_card.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/credit_cards/:id
      def destroy
        if @credit_card.credit_purchases.exists?
          render json: {
            error: 'No se puede eliminar la tarjeta porque tiene compras asociadas'
          }, status: :unprocessable_entity
        else
          @credit_card.destroy
          render json: { message: 'Tarjeta de crédito eliminada exitosamente' }
        end
      end

      # GET /api/v1/credit_cards/summary
      def summary
        cards = CreditCard.includes(:credit_purchases).active

        total_debt = cards.sum(&:total_debt)
        total_monthly_commitment = cards.sum(&:monthly_commitment)
        total_limit = cards.sum { |c| c.credit_limit || 0 }
        total_available = cards.sum(&:available_credit)

        overall_utilization = total_limit.zero? ? 0 : ((total_debt / total_limit) * 100).round(2)

        render json: {
          total_cards: cards.count,
          total_debt: total_debt,
          total_monthly_commitment: total_monthly_commitment,
          total_credit_limit: total_limit,
          total_available_credit: total_available,
          overall_utilization_percentage: overall_utilization,
          by_card: cards.map { |card|
            {
              id: card.id,
              name: card.display_name,
              debt: card.total_debt,
              monthly_payment: card.monthly_commitment,
              utilization: card.credit_utilization_percentage
            }
          }
        }
      end

      private

      def set_credit_card
        @credit_card = CreditCard.find(params[:id])
      end

      def credit_card_params
        params.require(:credit_card).permit(
          :user_id, :name, :bank_name, :cut_day, :credit_limit,
          :statement_day, :is_active, :notes
        )
      end
    end
  end
end
