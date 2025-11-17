module Api
  module V1
    class LendersController < ApplicationController
      before_action :set_lender, only: [:show, :update, :destroy]

      # GET /api/v1/lenders
      def index
        @lenders = Lender.includes(:loans).order(created_at: :desc)

        # Filtros
        @lenders = @lenders.active if params[:active] == 'true'
        @lenders = @lenders.investors if params[:relationship] == 'inversionista'
        @lenders = @lenders.family if params[:relationship] == 'familiar'
        @lenders = @lenders.friends if params[:relationship] == 'amigo'

        render json: @lenders.map { |lender|
          {
            id: lender.id,
            name: lender.name,
            contact_email: lender.contact_email,
            contact_phone: lender.contact_phone,
            relationship: lender.relationship,
            is_active: lender.is_active,
            notes: lender.notes,
            metrics: {
              total_lent: lender.total_lent,
              total_outstanding: lender.total_outstanding,
              total_paid: lender.total_paid,
              active_loans_count: lender.active_loans_count
            },
            created_at: lender.created_at,
            updated_at: lender.updated_at
          }
        }
      end

      # GET /api/v1/lenders/:id
      def show
        render json: {
          id: @lender.id,
          name: @lender.name,
          contact_email: @lender.contact_email,
          contact_phone: @lender.contact_phone,
          relationship: @lender.relationship,
          is_active: @lender.is_active,
          notes: @lender.notes,
          metrics: {
            total_lent: @lender.total_lent,
            total_outstanding: @lender.total_outstanding,
            total_paid: @lender.total_paid,
            active_loans_count: @lender.active_loans_count
          },
          loans: @lender.loans.order(loan_date: :desc).map { |loan|
            {
              id: loan.id,
              principal_amount: loan.principal_amount,
              interest_rate: loan.interest_rate,
              term_months: loan.term_months,
              loan_date: loan.loan_date,
              due_date: loan.due_date,
              remaining_balance: loan.remaining_balance,
              is_paid: loan.is_paid,
              monthly_payment: loan.monthly_payment,
              progress_percentage: loan.progress_percentage
            }
          },
          created_at: @lender.created_at,
          updated_at: @lender.updated_at
        }
      end

      # POST /api/v1/lenders
      def create
        @lender = Lender.new(lender_params)

        if @lender.save
          render json: {
            message: 'Prestamista creado exitosamente',
            lender: @lender
          }, status: :created
        else
          render json: { errors: @lender.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/lenders/:id
      def update
        if @lender.update(lender_params)
          render json: {
            message: 'Prestamista actualizado exitosamente',
            lender: @lender
          }
        else
          render json: { errors: @lender.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/lenders/:id
      def destroy
        if @lender.loans.exists?
          render json: {
            error: 'No se puede eliminar el prestamista porque tiene préstamos asociados'
          }, status: :unprocessable_entity
        else
          @lender.destroy
          render json: { message: 'Prestamista eliminado exitosamente' }
        end
      end

      # GET /api/v1/lenders/summary
      def summary
        lenders = Lender.includes(:loans).active

        total_outstanding = lenders.sum(&:total_outstanding)
        total_lent = lenders.sum(&:total_lent)
        total_paid = lenders.sum(&:total_paid)

        by_relationship = lenders.group_by(&:relationship).transform_values do |group_lenders|
          {
            count: group_lenders.count,
            total_outstanding: group_lenders.sum(&:total_outstanding),
            total_lent: group_lenders.sum(&:total_lent)
          }
        end

        render json: {
          total_lenders: lenders.count,
          total_amount_lent: total_lent,
          total_outstanding: total_outstanding,
          total_paid: total_paid,
          by_relationship: by_relationship,
          top_lenders: lenders.sort_by(&:total_outstanding).reverse.first(5).map { |lender|
            {
              id: lender.id,
              name: lender.display_name,
              total_outstanding: lender.total_outstanding,
              active_loans: lender.active_loans_count
            }
          }
        }
      end

      private

      def set_lender
        @lender = Lender.find(params[:id])
      end

      def lender_params
        params.require(:lender).permit(
          :name, :contact_email, :contact_phone, :relationship,
          :is_active, :notes
        )
      end
    end
  end
end
