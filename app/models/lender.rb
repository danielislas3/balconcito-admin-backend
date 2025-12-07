class Lender < ApplicationRecord
  has_many :loans, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :relationship, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :investors, -> { where(relationship: "inversionista") }
  scope :family, -> { where(relationship: "familiar") }
  scope :friends, -> { where(relationship: "amigo") }

  # Instance methods
  def total_lent
    loans.sum(:principal_amount)
  end

  def total_outstanding
    loans.where(is_paid: false).sum(:remaining_balance)
  end

  def total_paid
    loans.where(is_paid: true).sum(:principal_amount)
  end

  def active_loans_count
    loans.where(is_paid: false).count
  end

  def display_name
    "#{name} (#{relationship.capitalize})"
  end

  def contact_info
    [ contact_email, contact_phone ].compact.join(" / ")
  end
end
