module Api
  module V1
    module Loyverse
      class PaymentMappingsController < ApplicationController
        # GET /api/v1/loyverse/payment_mappings
        def index
          @mappings = LoyversePaymentMapping.includes(:payment_method).all

          render json: {
            mappings: @mappings.map do |mapping|
              {
                id: mapping.id,
                loyverse_payment_type_id: mapping.loyverse_payment_type_id,
                loyverse_payment_type: mapping.loyverse_payment_type,
                loyverse_payment_name: mapping.loyverse_payment_name,
                payment_method_id: mapping.payment_method_id,
                payment_method: mapping.payment_method ? {
                  id: mapping.payment_method.id,
                  name: mapping.payment_method.name,
                  payment_type: mapping.payment_method.payment_type
                } : nil,
                is_mapped: mapping.is_mapped?,
                created_at: mapping.created_at
              }
            end,
            summary: {
              total_mappings: @mappings.count,
              mapped_count: @mappings.select(&:is_mapped?).count,
              unmapped_count: @mappings.reject(&:is_mapped?).count
            }
          }
        end

        # PATCH /api/v1/loyverse/payment_mappings/:id
        def update
          @mapping = LoyversePaymentMapping.find(params[:id])

          if @mapping.update(mapping_params)
            render json: {
              success: true,
              message: "Mapeo actualizado exitosamente",
              mapping: {
                id: @mapping.id,
                loyverse_payment_type: @mapping.loyverse_payment_type,
                payment_method_id: @mapping.payment_method_id,
                is_mapped: @mapping.is_mapped?
              }
            }
          else
            render json: {
              success: false,
              errors: @mapping.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/loyverse/payment_mappings/sync
        def sync
          result = Loyverse::SyncService.new.sync_payment_types

          if result[:success]
            render json: {
              success: true,
              message: "Sincronizados #{result[:payment_types_synced]} payment types",
              data: {
                synced_count: result[:payment_types_synced],
                auto_mapped_count: result[:auto_mapped] || 0
              }
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

        def mapping_params
          params.permit(:payment_method_id)
        end
      end
    end
  end
end
