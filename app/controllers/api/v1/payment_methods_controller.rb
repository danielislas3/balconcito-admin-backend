module Api
  module V1
    class PaymentMethodsController < ApplicationController
      before_action :set_payment_method, only: [ :show, :update, :destroy ]

      # GET /api/v1/payment_methods
      def index
        @payment_methods = PaymentMethod.includes(:user).order(created_at: :desc)

        # Filtros
        @payment_methods = @payment_methods.where(user_id: params[:user_id]) if params[:user_id].present?
        @payment_methods = @payment_methods.active if params[:active] == 'true'
        @payment_methods = @payment_methods.where(payment_type: params[:payment_type]) if params[:payment_type].present?
        @payment_methods = @payment_methods.where(requires_reimbursement: params[:requires_reimbursement]) if params[:requires_reimbursement].present?

        render json: @payment_methods.as_json(
          include: {
            user: { only: [ :id, :name, :email ] }
          },
          methods: [ :display_name, :business_owned?, :personal_owned? ]
        )
      end

      # GET /api/v1/payment_methods/:id
      def show
        render json: @payment_method.as_json(
          include: {
            user: { only: [ :id, :name, :email ] }
          },
          methods: [ :display_name, :business_owned?, :personal_owned? ]
        )
      end

      # POST /api/v1/payment_methods
      def create
        @payment_method = PaymentMethod.new(payment_method_params)

        if @payment_method.save
          render json: @payment_method.as_json(
            include: {
              user: { only: [ :id, :name, :email ] }
            },
            methods: [ :display_name, :business_owned?, :personal_owned? ]
          ), status: :created
        else
          render json: { errors: @payment_method.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/payment_methods/:id
      def update
        if @payment_method.update(payment_method_params)
          render json: @payment_method.as_json(
            include: {
              user: { only: [ :id, :name, :email ] }
            },
            methods: [ :display_name, :business_owned?, :personal_owned? ]
          )
        else
          render json: { errors: @payment_method.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/payment_methods/:id
      def destroy
        if @payment_method.expenses.any?
          render json: { error: 'No se puede eliminar un método de pago con gastos asociados' }, status: :unprocessable_entity
        else
          @payment_method.destroy
          head :no_content
        end
      end

      private

      def set_payment_method
        @payment_method = PaymentMethod.find(params[:id])
      end

      def payment_method_params
        params.require(:payment_method).permit(
          :user_id, :name, :payment_type, :requires_reimbursement, :is_active, :description
        )
      end
    end
  end
end
