# == Schema Information
#
# Table name: loyverse_payment_mappings
#
#  id                        :bigint           not null, primary key
#  loyverse_payment_type_id  :string           not null
#  loyverse_payment_name     :string           not null
#  loyverse_payment_type     :string
#  payment_method_id         :bigint
#  is_active                 :boolean          default(TRUE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class LoyversePaymentMapping < ApplicationRecord
  belongs_to :payment_method, optional: true

  validates :loyverse_payment_type_id, presence: true, uniqueness: true
  validates :loyverse_payment_name, presence: true

  scope :active, -> { where(is_active: true) }
  scope :cash, -> { where(loyverse_payment_type: 'CASH') }
  scope :card, -> { where(loyverse_payment_type: 'CARD') }
  scope :custom, -> { where(loyverse_payment_type: 'CUSTOM') }
  scope :mapped, -> { where.not(payment_method_id: nil) }
  scope :unmapped, -> { where(payment_method_id: nil) }

  # Crear mapping desde API de Loyverse
  def self.create_from_loyverse_data(payment_type_data)
    find_or_create_by!(loyverse_payment_type_id: payment_type_data['id']) do |mapping|
      mapping.loyverse_payment_name = payment_type_data['name']
      mapping.loyverse_payment_type = payment_type_data['type']
    end
  end

  # Auto-mapear basado en tipo
  def auto_map!
    method = case loyverse_payment_type
             when 'CASH'
               PaymentMethod.find_by(payment_type: 'cash')
             when 'CARD'
               PaymentMethod.find_by(payment_type: 'card')
             when 'CUSTOM'
               # Intentar encontrar por nombre (ej: "Transferencia", "QR", etc.)
               PaymentMethod.find_by(payment_type: 'transfer')
             end

    update!(payment_method: method) if method
  end

  # ¿Está mapeado?
  def mapped?
    payment_method_id.present?
  end

  def unmapped?
    !mapped?
  end
end
