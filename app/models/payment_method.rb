class PaymentMethod < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :restrict_with_error

  # Enums
  enum :payment_type, {
    business_cash: "efectivo_negocio",
    business_transfer: "transferencia_negocio",
    business_card: "tarjeta_negocio",
    personal_card: "tarjeta_personal",
    personal_cash: "efectivo_personal",
    other: "otro"
  }, validate: true

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, message: "ya existe para este usuario" }
  validates :payment_type, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :business_methods, -> { where(payment_type: [ :business_cash, :business_transfer, :business_card ]) }
  scope :personal_methods, -> { where(payment_type: [ :personal_card, :personal_cash ]) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def display_name
    "#{name} (#{payment_type_i18n})"
  end

  def business_owned?
    business_cash? || business_transfer? || business_card?
  end

  def personal_owned?
    personal_card? || personal_cash?
  end

  private

  def payment_type_i18n
    I18n.t("activerecord.attributes.payment_method.payment_types.#{payment_type}", default: payment_type.humanize)
  end
end
