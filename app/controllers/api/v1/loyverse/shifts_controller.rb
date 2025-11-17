module Api
  module V1
    module Loyverse
      class ShiftsController < ApplicationController
        before_action :set_shift, only: [:show]

        # GET /api/v1/loyverse/shifts
        def index
          @shifts = LoyverseShift.includes(:turn_closure, :loyverse_receipts)
                                 .order(closed_at: :desc)
                                 .page(params[:page])
                                 .per(params[:per_page] || 20)

          # Filtros opcionales
          @shifts = @shifts.without_turn_closure if params[:unconverted] == 'true'
          @shifts = @shifts.with_turn_closure if params[:converted] == 'true'
          @shifts = @shifts.where('closed_at >= ?', params[:start_date]) if params[:start_date].present?
          @shifts = @shifts.where('closed_at <= ?', params[:end_date]) if params[:end_date].present?

          render json: {
            shifts: @shifts.map { |s| shift_json(s) },
            meta: pagination_meta(@shifts)
          }
        end

        # GET /api/v1/loyverse/shifts/:id
        def show
          render json: {
            shift: shift_detail_json(@shift)
          }
        end

        private

        def set_shift
          @shift = LoyverseShift.find(params[:id])
        end

        def shift_json(shift)
          {
            id: shift.id,
            loyverse_id: shift.loyverse_id,
            store_id: shift.store_id,
            opened_at: shift.opened_at,
            closed_at: shift.closed_at,
            opened_by_employee: shift.opened_by_employee,
            closed_by_employee: shift.closed_by_employee,
            duration_hours: shift.duration_hours,

            # Totales de efectivo
            starting_cash: shift.starting_cash,
            cash_payments: shift.cash_payments,
            expected_cash: shift.expected_cash,
            actual_cash: shift.actual_cash,
            cash_difference: shift.cash_difference,
            cash_status: shift.cash_status,
            cash_balanced: shift.cash_balanced?,

            # Totales de ventas
            gross_sales: shift.gross_sales,
            refunds: shift.refunds,
            discounts: shift.discounts,

            # Totales calculados por payment type (desde receipts)
            payment_totals: shift.calculate_payment_totals,

            # Metadata
            receipts_count: shift.loyverse_receipts.count,
            converted: shift.converted?,
            turn_closure_id: shift.turn_closure_id,

            # Stats
            sales_per_hour: shift.sales_per_hour
          }
        end

        def shift_detail_json(shift)
          shift_json(shift).merge(
            receipts: shift.loyverse_receipts.map do |receipt|
              {
                id: receipt.id,
                receipt_number: receipt.receipt_number,
                total_money: receipt.total_money,
                loyverse_created_at: receipt.loyverse_created_at,
                payment_totals: {
                  cash: receipt.cash_total,
                  card: receipt.card_total,
                  custom: receipt.custom_payment_total
                }
              }
            end,
            full_data: shift.shift_data
          )
        end

        def pagination_meta(collection)
          {
            current_page: collection.current_page,
            next_page: collection.next_page,
            prev_page: collection.prev_page,
            total_pages: collection.total_pages,
            total_count: collection.total_count
          }
        end
      end
    end
  end
end
