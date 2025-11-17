module Api
  module V1
    class TurnClosuresController < ApplicationController
      before_action :set_turn_closure, only: [:show, :update, :destroy]

      # GET /api/v1/turn_closures
      def index
        turn_closures = TurnClosure.all.order(report_date: :desc)

        # Filtros opcionales
        turn_closures = turn_closures.where('report_date >= ?', params[:date_from]) if params[:date_from]
        turn_closures = turn_closures.where('report_date <= ?', params[:date_to]) if params[:date_to]
        turn_closures = turn_closures.where(closed_by: params[:closed_by]) if params[:closed_by]

        render json: {
          turn_closures: turn_closures.as_json(
            only: [:id, :closure_number, :report_date, :cash_collected, :transfer_income,
                   :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at],
            methods: [:total_income]
          ),
          summary: {
            total_closures: turn_closures.count,
            total_income: turn_closures.sum(&:total_income),
            total_cash: turn_closures.sum(:cash_collected),
            total_transfers: turn_closures.sum(:transfer_income),
            total_cards: turn_closures.sum(:card_income)
          }
        }
      end

      # GET /api/v1/turn_closures/:id
      def show
        render json: {
          turn_closure: @turn_closure.as_json(
            only: [:id, :closure_number, :report_date, :cash_collected, :transfer_income,
                   :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at],
            methods: [:total_income]
          )
        }
      end

      # POST /api/v1/turn_closures
      def create
        turn_closure = current_user.turn_closures.new(turn_closure_params)

        if turn_closure.save
          render json: {
            turn_closure: turn_closure.as_json(
              only: [:id, :closure_number, :report_date, :cash_collected, :transfer_income,
                     :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at],
              methods: [:total_income]
            ),
            message: 'Cierre registrado exitosamente'
          }, status: :created
        else
          render_error(turn_closure.errors.full_messages.join(', '))
        end
      end

      # PATCH /api/v1/turn_closures/:id
      def update
        if @turn_closure.update(turn_closure_params)
          render json: {
            turn_closure: @turn_closure.as_json(
              only: [:id, :closure_number, :report_date, :cash_collected, :transfer_income,
                     :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at],
              methods: [:total_income]
            ),
            message: 'Cierre actualizado exitosamente'
          }
        else
          render_error(@turn_closure.errors.full_messages.join(', '))
        end
      end

      # DELETE /api/v1/turn_closures/:id
      def destroy
        if @turn_closure.destroy
          render json: { message: 'Cierre eliminado exitosamente' }
        else
          render_error('No se pudo eliminar el cierre')
        end
      end

      private

      def set_turn_closure
        @turn_closure = TurnClosure.find(params[:id])
      end

      def turn_closure_params
        params.require(:turn_closure).permit(
          :closure_number, :report_date, :cash_collected, :transfer_income,
          :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes
        )
      end
    end
  end
end
