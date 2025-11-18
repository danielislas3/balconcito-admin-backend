# == Schema Information
#
# Table name: loyverse_configs
#
#  id                       :integer          not null, primary key
#  api_token_encrypted      :text
#  webhook_secret_encrypted :text
#  payment_type_mappings    :jsonb            not null
#  last_sync_at             :datetime
#  sync_enabled             :boolean          default(TRUE), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class LoyverseConfig < ApplicationRecord
  # Solo debe haber un registro de configuración
  validates :id, inclusion: { in: [1] }

  # Encriptación de tokens (requiere rails credentials o attr_encrypted gem)
  # Por ahora usamos campos de texto, en producción usar encriptación
  attribute :api_token, :string
  attribute :webhook_secret, :string

  # Obtener la instancia única de configuración
  def self.instance
    first_or_create!(id: 1)
  end

  # Configurar API token
  def api_token=(value)
    self.api_token_encrypted = value # TODO: Encriptar en producción
  end

  def api_token
    # Prioridad: ENV > Base de datos
    ENV['LOYVERSE_API_TOKEN'].presence || api_token_encrypted
  end

  # Configurar webhook secret
  def webhook_secret=(value)
    self.webhook_secret_encrypted = value # TODO: Encriptar en producción
  end

  def webhook_secret
    webhook_secret_encrypted # TODO: Desencriptar en producción
  end

  # Actualizar última sincronización
  def update_last_sync!
    update!(last_sync_at: Time.current)
  end

  # Habilitar/deshabilitar sync
  def enable_sync!
    update!(sync_enabled: true)
  end

  def disable_sync!
    update!(sync_enabled: false)
  end

  # Mapear payment type de Loyverse a PaymentMethod
  def map_payment_type(loyverse_type_id, payment_method_id)
    mappings = payment_type_mappings.dup
    mappings[loyverse_type_id] = payment_method_id
    update!(payment_type_mappings: mappings)
  end

  def get_payment_method_id(loyverse_type_id)
    payment_type_mappings[loyverse_type_id]
  end

  # ¿Está configurado?
  def configured?
    api_token.present?
  end

  # ¿Sync habilitado?
  def sync_active?
    sync_enabled && configured?
  end
end
