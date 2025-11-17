module Api
  module V1
    module Loyverse
      class WebhooksController < ApplicationController
        skip_before_action :verify_authenticity_token, only: [:create]

        # POST /api/v1/loyverse/webhooks
        def create
          # Guardar evento
          event = LoyverseWebhookEvent.create!(
            event_id: webhook_params[:event_id],
            event_type: webhook_params[:event_type],
            payload: request.body.read,
            signature: request.headers['X-Loyverse-Webhook-Signature']
          )

          # Procesar asíncronamente
          process_webhook(event)

          head :ok
        rescue => e
          Rails.logger.error("Error procesando webhook de Loyverse: #{e.message}")
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

          render json: { message: 'Webhook reintentado', event: event }
        end

        private

        def webhook_params
          JSON.parse(request.body.read).with_indifferent_access
        rescue JSON::ParserError
          {}
        end

        def process_webhook(event)
          return unless event.supported?

          case event.event_type
          when LoyverseWebhookEvent::RECEIPT_CREATED
            process_receipt_created(event)
          when LoyverseWebhookEvent::RECEIPT_UPDATED
            process_receipt_updated(event)
          when LoyverseWebhookEvent::SHIFT_CLOSED
            process_shift_closed(event)
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

          # Create LoyverseReceipt
          loyverse_receipt = LoyverseReceipt.find_or_create_by!(loyverse_id: receipt_data['id']) do |r|
            r.receipt_number = receipt_data['receipt_number']
            r.receipt_type = receipt_data['receipt_type']
            r.total_money = receipt_data['total_money']
            r.total_tax = receipt_data['total_tax']
            r.receipt_data = receipt_data
            r.loyverse_created_at = receipt_data['created_at']
            r.synced_at = Time.current
          end

          # Create TurnClosure
          unless loyverse_receipt.converted?
            ::Loyverse::ReceiptMapper.new(loyverse_receipt).create_turn_closure
          end

          Rails.logger.info("✅ Webhook RECEIPT_CREATED procesado: #{receipt_id}")
        end

        def process_receipt_updated(event)
          # Similar a process_receipt_created
          process_receipt_created(event)
        end

        def process_shift_closed(event)
          # Opcional: sincronizar receipts del turno cerrado
          Rails.logger.info("ℹ️  SHIFT_CLOSED webhook recibido")
        end
      end
    end
  end
end
