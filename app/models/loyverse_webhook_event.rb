# == Schema Information
#
# Table name: loyverse_webhook_events
#
#  id            :bigint           not null, primary key
#  event_id      :string
#  event_type    :string           not null
#  payload       :jsonb            not null
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error_message :text
#  signature     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class LoyverseWebhookEvent < ApplicationRecord
  validates :event_type, presence: true
  validates :payload, presence: true
  validates :event_id, uniqueness: true, allow_nil: true

  scope :unprocessed, -> { where(processed: false) }
  scope :processed, -> { where(processed: true) }
  scope :failed, -> { where.not(error_message: nil) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :recent, -> { order(created_at: :desc) }

  # Eventos disponibles en Loyverse
  RECEIPT_CREATED = 'RECEIPT_CREATED'
  RECEIPT_UPDATED = 'RECEIPT_UPDATED'
  RECEIPT_DELETED = 'RECEIPT_DELETED'
  ITEM_CREATED = 'ITEM_CREATED'
  ITEM_UPDATED = 'ITEM_UPDATED'
  ITEM_DELETED = 'ITEM_DELETED'
  SHIFT_OPENED = 'SHIFT_OPENED'
  SHIFT_CLOSED = 'SHIFT_CLOSED'
  INVENTORY_UPDATED = 'INVENTORY_UPDATED'

  SUPPORTED_EVENTS = [
    RECEIPT_CREATED,
    RECEIPT_UPDATED,
    SHIFT_CLOSED
  ].freeze

  # Marcar como procesado
  def mark_as_processed!
    update!(processed: true, processed_at: Time.current)
  end

  # Marcar como fallido
  def mark_as_failed!(error)
    update!(
      processed: false,
      error_message: error.to_s,
      processed_at: Time.current
    )
  end

  # ¿Es un evento soportado?
  def supported?
    SUPPORTED_EVENTS.include?(event_type)
  end

  # Extraer datos del payload
  def receipt_id
    payload.dig('id')
  end

  def resource_type
    payload.dig('resource_type')
  end

  def resource_id
    payload.dig('resource_id')
  end

  # Retry procesamiento
  def retry_processing!
    update!(processed: false, error_message: nil, processed_at: nil)
  end
end
