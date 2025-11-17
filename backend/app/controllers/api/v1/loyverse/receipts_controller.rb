module Api
  module V1
    module Loyverse
      class ReceiptsController < ApplicationController
        before_action :set_receipt, only: [:show]

        # GET /api/v1/loyverse/receipts
        def index
          @receipts = LoyverseReceipt.includes(:turn_closure, :loyverse_shift)
                                     .order(loyverse_created_at: :desc)
                                     .page(params[:page])
                                     .per(params[:per_page] || 50)

          # Filtros opcionales
          @receipts = @receipts.by_date(params[:date]) if params[:date].present?
          @receipts = @receipts.date_range(params[:start_date], params[:end_date]) if params[:start_date].present?
          @receipts = @receipts.sales if params[:type] == 'sale'
          @receipts = @receipts.refunds if params[:type] == 'refund'
          @receipts = @receipts.where(turn_closure_id: nil) if params[:unconverted] == 'true'

          render json: {
            receipts: @receipts.map { |r| receipt_json(r) },
            meta: pagination_meta(@receipts)
          }
        end

        # GET /api/v1/loyverse/receipts/:id
        def show
          render json: {
            receipt: receipt_detail_json(@receipt)
          }
        end

        # POST /api/v1/loyverse/receipts/sync
        def sync
          start_date = params[:start_date] || Date.today.to_s
          end_date = params[:end_date] || Date.today.to_s

          result = Loyverse::SyncService.new(
            start_date: start_date,
            end_date: end_date
          ).sync_receipts

          if result[:success]
            render json: {
              success: true,
              message: "Sincronizados #{result[:receipts_synced]} receipts",
              data: result
            }
          else
            render json: {
              success: false,
              error: result[:error]
            }, status: :unprocessable_entity
          end
        rescue => e
          render json: {
            success: false,
            error: e.message
          }, status: :internal_server_error
        end

        private

        def set_receipt
          @receipt = LoyverseReceipt.find(params[:id])
        end

        def receipt_json(receipt)
          {
            id: receipt.id,
            loyverse_id: receipt.loyverse_id,
            receipt_number: receipt.receipt_number,
            receipt_type: receipt.receipt_type,
            total_money: receipt.total_money,
            total_tax: receipt.total_tax,
            loyverse_created_at: receipt.loyverse_created_at,
            synced_at: receipt.synced_at,
            converted: receipt.converted?,
            turn_closure_id: receipt.turn_closure_id,
            shift_id: receipt.loyverse_shift_id,
            payment_totals: {
              cash: receipt.cash_total,
              card: receipt.card_total,
              custom: receipt.custom_payment_total
            }
          }
        end

        def receipt_detail_json(receipt)
          receipt_json(receipt).merge(
            payments: receipt.payments,
            line_items: receipt.line_items,
            employee_id: receipt.employee_id,
            store_id: receipt.store_id,
            pos_device_id: receipt.pos_device_id,
            full_data: receipt.receipt_data
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
