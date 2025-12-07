class PayrollEmployee < ApplicationRecord
  # Associations
  belongs_to :user, optional: true
  has_many :payroll_weeks, dependent: :destroy
  has_many :payroll_days, through: :payroll_weeks

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :employee_id, presence: true, uniqueness: { case_sensitive: false }
  validates :base_hourly_rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10000 }
  validates :currency, presence: true, inclusion: { in: %w[MXN USD EUR] }

  # Validaciones de configuración de overtime
  validates :overtime_tier1_rate, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :overtime_tier2_rate, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :overtime_tier1_hours, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 12 }

  # Validaciones de configuración de horarios
  validates :hours_per_shift, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validates :break_hours, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }
  validates :min_hours_for_break, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 12 }

  # Validaciones lógicas custom
  validate :tier2_rate_must_be_higher_than_tier1
  validate :break_hours_must_be_less_than_shift

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

  def tier2_rate_must_be_higher_than_tier1
    return unless overtime_tier1_rate && overtime_tier2_rate

    if overtime_tier2_rate < overtime_tier1_rate
      errors.add(:overtime_tier2_rate, 'debe ser mayor o igual que overtime_tier1_rate')
    end
  end

  def break_hours_must_be_less_than_shift
    return unless break_hours && hours_per_shift

    if break_hours >= hours_per_shift
      errors.add(:break_hours, 'debe ser menor que hours_per_shift')
    end
  end
end
