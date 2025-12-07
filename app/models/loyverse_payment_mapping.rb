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
  scope :cash, -> { where(loyverse_payment_type: "CASH") }
  scope :card, -> { where(loyverse_payment_type: "CARD") }
  scope :custom, -> { where(loyverse_payment_type: "CUSTOM") }
  scope :mapped, -> { where.not(payment_method_id: nil) }
  scope :unmapped, -> { where(payment_method_id: nil) }

  # Crear mapping desde API de Loyverse
  def self.create_from_loyverse_data(payment_type_data)
    find_or_create_by!(loyverse_payment_type_id: payment_type_data["id"]) do |mapping|
      mapping.loyverse_payment_name = payment_type_data["name"]
      mapping.loyverse_payment_type = payment_type_data["type"]
    end
  end

  # Auto-mapear basado en tipo y nombre
  # Busca PaymentMethods que coincidan por nombre o tipo
  def auto_map!
    method = case loyverse_payment_type
    when "CASH"
               # Buscar por nombre (Bóveda, Caja, Efectivo) o payment_type que contenga 'cash'
               PaymentMethod.where("name ILIKE ? OR payment_type ILIKE ?", "%efectivo%", "%cash%")
                           .or(PaymentMethod.where("name ILIKE ?", "%bóveda%"))
                           .or(PaymentMethod.where("name ILIKE ?", "%caja%"))
                           .first
    when "CARD", "NONINTEGRATEDCARD"
               # Buscar por nombre (Tarjeta) o payment_type que contenga 'card'
               # Nota: Las tarjetas suelen ir a cuenta digital/Mercado Pago
               PaymentMethod.where("name ILIKE ? OR payment_type ILIKE ?", "%tarjeta%", "%card%")
                           .or(PaymentMethod.where("name ILIKE ?", "%transferencia%"))
                           .first
    when "OTHER", "CUSTOM"
               # Transferencias/QR - buscar por nombre o payment_type
               PaymentMethod.where("name ILIKE ? OR payment_type ILIKE ?", "%transferencia%", "%transfer%")
                           .or(PaymentMethod.where("name ILIKE ?", "%mercado pago%"))
                           .or(PaymentMethod.where("name ILIKE ?", "%qr%"))
                           .first
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
