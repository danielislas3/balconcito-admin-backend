module Api
  module V1
    class TurnClosuresController < ApplicationController
      before_action :set_turn_closure, only: [ :show, :update, :destroy, :validate_with_loyverse ]

      # GET /api/v1/turn_closures
      def index
        turn_closures = TurnClosure.all.order(report_date: :desc)

        # Filtros opcionales
        turn_closures = turn_closures.where("report_date >= ?", params[:date_from]) if params[:date_from]
        turn_closures = turn_closures.where("report_date <= ?", params[:date_to]) if params[:date_to]
        turn_closures = turn_closures.where(closed_by: params[:closed_by]) if params[:closed_by]

        render json: {
          turn_closures: turn_closures.as_json(
            only: [ :id, :closure_number, :report_date, :cash_collected, :transfer_income,
                   :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at ],
            methods: [ :total_income ]
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
            only: [ :id, :closure_number, :report_date, :cash_collected, :transfer_income,
                   :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at ],
            methods: [ :total_income ]
          )
        }
      end

      # POST /api/v1/turn_closures
      def create
        turn_closure = current_user.turn_closures.new(turn_closure_params)

        if turn_closure.save
          render json: {
            turn_closure: turn_closure.as_json(
              only: [ :id, :closure_number, :report_date, :cash_collected, :transfer_income,
                     :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at ],
              methods: [ :total_income ]
            ),
            message: "Cierre registrado exitosamente"
          }, status: :created
        else
          render_error(turn_closure.errors.full_messages.join(", "))
        end
      end

      # PATCH /api/v1/turn_closures/:id
      def update
        if @turn_closure.update(turn_closure_params)
          render json: {
            turn_closure: @turn_closure.as_json(
              only: [ :id, :closure_number, :report_date, :cash_collected, :transfer_income,
                     :card_income, :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :created_at ],
              methods: [ :total_income ]
            ),
            message: "Cierre actualizado exitosamente"
          }
        else
          render_error(@turn_closure.errors.full_messages.join(", "))
        end
      end

      # DELETE /api/v1/turn_closures/:id
      def destroy
        if @turn_closure.from_loyverse?
          return render json: {
            success: false,
            error: "No se puede eliminar un cierre creado automáticamente desde Loyverse"
          }, status: :forbidden
        end

        if @turn_closure.destroy
          render json: { success: true, message: "Cierre eliminado exitosamente" }
        else
          render json: { success: false, error: "No se pudo eliminar el cierre" }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/turn_closures/:id/validate_with_loyverse
      # Valida manualmente un TurnClosure contra Loyverse
      def validate_with_loyverse
        result = @turn_closure.validate_with_loyverse

        render json: {
          success: true,
          validation: result,
          turn_closure: {
            id: @turn_closure.id,
            closure_number: @turn_closure.closure_number,
            validation_status: @turn_closure.validation_status,
            has_errors: @turn_closure.has_validation_errors?,
            has_warnings: @turn_closure.has_validation_warnings?
          }
        }
      end

      # POST /api/v1/turn_closures/preview_validation
      # Preview de validación SIN crear el TurnClosure
      def preview_validation
        # Crear instancia temporal (no guardar)
        @turn_closure = TurnClosure.new(turn_closure_params)

        # Validar contra Loyverse
        validator = TurnClosures::Validator.new(@turn_closure)
        result = validator.validate

        render json: {
          success: true,
          can_create: result[:valid] || result[:errors].none? { |e| e[:severity] == "critical" },
          validation: result,
          recommendation: generate_recommendation(result)
        }
      end

      private

      def set_turn_closure
        @turn_closure = TurnClosure.find(params[:id])
      end

      def turn_closure_params
        params.require(:turn_closure).permit(
          :closure_number, :closure_date, :report_date, :cash_collected, :transfer_income,
          :card_income, :card_income_gross, :transfer_income_gross, :total_income,
          :closed_by, :theoretical_cash, :payments_withdrawals, :notes, :user_id
        )
      end

      def generate_recommendation(result)
        if result[:errors].empty? && result[:warnings].empty?
          "Datos correctos. Puedes crear el cierre de caja."
        elsif result[:errors].any? { |e| e[:severity] == "critical" }
          "HAY ERRORES CRÍTICOS. Verifica los montos antes de continuar."
        elsif result[:warnings].any?
          "Hay diferencias menores. Revisa las advertencias y decide si continuar."
        else
          "No se pudo validar contra Loyverse."
        end
      end
    end
  end
end
