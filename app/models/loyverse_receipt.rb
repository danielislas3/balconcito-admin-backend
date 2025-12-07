# == Schema Information
#
# Table name: loyverse_receipts
#
#  id                  :bigint           not null, primary key
#  loyverse_id         :string           not null
#  receipt_number      :string
#  receipt_type        :string
#  total_money         :decimal(15, 2)
#  total_tax           :decimal(15, 2)
#  receipt_data        :jsonb            not null
#  loyverse_created_at :datetime
#  synced_at           :datetime
#  turn_closure_id     :bigint
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class LoyverseReceipt < ApplicationRecord
  belongs_to :turn_closure, optional: true
  belongs_to :loyverse_shift, optional: true

  validates :loyverse_id, presence: true, uniqueness: true
  validates :receipt_data, presence: true

  scope :synced, -> { where.not(synced_at: nil) }
  scope :unsynced, -> { where(synced_at: nil) }
  scope :sales, -> { where(receipt_type: "SALE") }
  scope :refunds, -> { where(receipt_type: "REFUND") }
  scope :by_date, ->(date) { where("DATE(loyverse_created_at) = ?", date) }
  scope :date_range, ->(start_date, end_date) {
    where(loyverse_created_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  # Marcar como sincronizado
  def mark_as_synced!
    update!(synced_at: Time.current)
  end

  # Extraer información del JSON
  def payments
    receipt_data.dig("payments") || []
  end

  def line_items
    receipt_data.dig("line_items") || []
  end

  def employee_id
    receipt_data.dig("employee_id")
  end

  def store_id
    receipt_data.dig("store_id")
  end

  def pos_device_id
    receipt_data.dig("pos_device_id")
  end

  # Total por tipo de pago
  def total_by_payment_type(type)
    payments
      .select { |p| p["type"] == type }
      .sum { |p| p["money_amount"].to_f }
  end

  def cash_total
    total_by_payment_type("CASH")
  end

  def card_total
    total_by_payment_type("CARD")
  end

  def custom_payment_total
    total_by_payment_type("CUSTOM")
  end

  # ¿Ya fue convertido a TurnClosure?
  def converted?
    turn_closure_id.present?
  end

  # JSON completo del receipt para debugging
  def full_data
    receipt_data
  end
end
