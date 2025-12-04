class PayrollEmployee < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :payroll_weeks, dependent: :destroy
  has_many :payroll_days, through: :payroll_weeks

  # Validations
  validates :name, presence: true
  validates :employee_id, presence: true, uniqueness: true
  validates :base_hourly_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, inclusion: { in: %w[MXN USD EUR] }
  validates :overtime_tier1_rate, numericality: { greater_than_or_equal_to: 1 }, allow_nil: true
  validates :overtime_tier2_rate, numericality: { greater_than_or_equal_to: 1 }, allow_nil: true
  validates :overtime_tier1_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :hours_per_shift, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :break_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_hours_for_break, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :active, -> { where(user_id: User.where.not(role: 'inactive')) }
  scope :by_name, -> { order(:name) }

  # Callbacks
  before_validation :generate_employee_id, on: :create

  # Instance methods
  def settings
    {
      baseHourlyRate: base_hourly_rate.to_f,
      currency: currency,
      usesOvertime: uses_overtime,
      usesTips: uses_tips,
      overtimeTier1Rate: overtime_tier1_rate.to_f,
      overtimeTier2Rate: overtime_tier2_rate.to_f,
      overtimeTier1Hours: overtime_tier1_hours,
      hoursPerShift: hours_per_shift,
      breakHours: break_hours,
      minHoursForBreak: min_hours_for_break
    }
  end

  def to_frontend_json
    {
      id: employee_id,
      name: name,
      settings: settings,
      weeks: payroll_weeks.order(start_date: :desc).map(&:to_frontend_json)
    }
  end

  private

  def generate_employee_id
    return if employee_id.present?

    # Generar ID basado en nombre y timestamp
    base = name.parameterize
    timestamp = Time.current.to_i
    self.employee_id = "#{base}-#{timestamp}"
  end
end
