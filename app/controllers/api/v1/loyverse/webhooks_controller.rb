module Api
  module V1
    module Loyverse
      class WebhooksController < ApplicationController
        # Webhooks vienen de Loyverse, no tienen JWT
        skip_before_action :authenticate_user!, only: [ :create ]
        #skip_before_action :verify_authenticity_token, only: [ :create ]

        # POST /api/v1/loyverse/webhooks
        def create
          # Leer payload una sola vez
          payload_body = request.body.read
          payload_json = JSON.parse(payload_body) rescue {}

          # Guardar evento
          event = LoyverseWebhookEvent.create!(
            event_id: payload_json["event_id"],
            event_type: payload_json["event_type"],
            payload: payload_json,
            signature: request.headers["X-Loyverse-Webhook-Signature"]
          )

          # Procesar asíncronamente
          process_webhook(event)

          head :ok
        rescue => e
          Rails.logger.error("Error procesando webhook de Loyverse: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          head :unprocessable_entity
        end

        # GET /api/v1/loyverse/webhooks (admin)
        def index
          events = LoyverseWebhookEvent.order(created_at: :desc).limit(100)
          render json: events
        end

        # POST /api/v1/loyverse/webhooks/:id/retry (admin)
        def retry
          event = LoyverseWebhookEvent.find(params[:id])
          event.retry_processing!
          process_webhook(event)

          render json: { message: "Webhook reintentado", event: event }
        end

        private

        def process_webhook(event)
          return unless event.supported?

          case event.event_type
          when LoyverseWebhookEvent::RECEIPT_CREATED
            process_receipt_created(event)
          when LoyverseWebhookEvent::RECEIPT_UPDATED
            process_receipt_updated(event)
          when LoyverseWebhookEvent::SHIFT_CLOSED, LoyverseWebhookEvent::SHIFT_CREATED
            process_shift_created(event)
          end

          event.mark_as_processed!
        rescue => e
          event.mark_as_failed!(e)
        end

        def process_receipt_created(event)
          receipt_id = event.receipt_id

          # Fetch full receipt data from Loyverse API
          client = ::Loyverse::Client.new
          receipt_data = client.get_receipt(receipt_id)

          # Create/Update LoyverseReceipt (solo guardar, NO crear TurnClosure)
          # Los TurnClosures se crean desde SHIFTS, no desde receipts individuales
          loyverse_receipt = LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_data["receipt_number"]) do |r|
            r.receipt_number = receipt_data["receipt_number"]
            r.receipt_type = receipt_data["receipt_type"]
            r.total_money = receipt_data["total_money"]
            r.total_tax = receipt_data["total_tax"]
            r.receipt_data = receipt_data
            r.loyverse_created_at = receipt_data["created_at"]
            r.synced_at = Time.current
          end

          Rails.logger.info("✅ Webhook RECEIPT_CREATED procesado: #{receipt_id}")
          Rails.logger.info("   Receipt guardado, TurnClosure se creará cuando se cierre el shift")
        end

        def process_receipt_updated(event)
          # Similar a process_receipt_created
          process_receipt_created(event)
        end

        def process_shift_created(event)
          shift_id = event.shift_id

          Rails.logger.info("🔔 Webhook SHIFT_CREATED recibido: #{shift_id}")

          # Procesar shift usando estrategia híbrida (Shift + Receipts)
          result = ::Loyverse::ShiftProcessor.new(shift_id).process

          if result[:success]
            Rails.logger.info("✅ Shift procesado: TurnClosure ##{result[:turn_closure]&.closure_number}")
          else
            Rails.logger.error("❌ Error procesando shift: #{result[:error]}")
            raise result[:error]
          end
        end
      end
    end
  end
end
