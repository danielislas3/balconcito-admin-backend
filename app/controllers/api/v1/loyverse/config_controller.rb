module Api
  module V1
    module Loyverse
      class ConfigController < ApplicationController
        # GET /api/v1/loyverse/config
        def show
          @config = LoyverseConfig.instance

          render json: {
            config: {
              id: @config.id,
              api_token_present: @config.api_token.present?,
              api_token_preview: masked_token(@config.api_token),
              webhook_secret_present: @config.webhook_secret.present?,
              last_sync_at: @config.last_sync_at,
              sync_enabled: @config.sync_enabled,
              configured: @config.configured?,
              sync_active: @config.sync_active?,
              created_at: @config.created_at,
              updated_at: @config.updated_at
            }
          }
        end

        # PATCH /api/v1/loyverse/config
        def update
          @config = LoyverseConfig.instance

          # Validar que el nuevo API token sea válido (opcional)
          if params[:api_token].present?
            unless validate_api_token(params[:api_token])
              return render json: {
                success: false,
                error: "API token inválido o no puede conectar con Loyverse"
              }, status: :unprocessable_entity
            end
          end

          if @config.update(config_params)
            render json: {
              success: true,
              message: "Configuración actualizada exitosamente",
              config: {
                api_token_present: @config.api_token.present?,
                sync_enabled: @config.sync_enabled,
                configured: @config.configured?,
                last_sync_at: @config.last_sync_at
              }
            }
          else
            render json: {
              success: false,
              errors: @config.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def config_params
          params.permit(:api_token, :webhook_secret, :sync_enabled)
        end

        def masked_token(token)
          return nil if token.blank?
          return token if token.length < 8

          # Mostrar solo primeros 4 y últimos 4 caracteres
          "#{token[0..3]}#{'*' * (token.length - 8)}#{token[-4..-1]}"
        end

        def validate_api_token(token)
          # Intenta hacer una request simple a Loyverse para validar el token
          client = ::Loyverse::Client.new(token)
          client.get_stores
          true
        rescue => e
          Rails.logger.error("Error validando API token: #{e.message}")
          false
        end
      end
    end
  end
end
