class PayrollWeek < ApplicationRecord
  # Associations
  belongs_to :payroll_employee
  has_many :payroll_days, dependent: :destroy

  # Validations
  validates :week_id, presence: true, uniqueness: { scope: :payroll_employee_id }
  validates :start_date, :end_date, presence: true
  validates :weekly_tips, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :end_date_after_start_date

  # Scopes
  scope :by_date, -> { order(start_date: :desc) }
  scope :for_period, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date, end_date) }
  scope :current_week, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }

  # Callbacks
  after_initialize :build_days, if: :new_record?
  before_save :calculate_totals

  # Instance methods
  def schedule
    days = {}
    day_keys = %w[monday tuesday wednesday thursday friday saturday sunday]

    day_keys.each do |day_key|
      day = payroll_days.find_by(day_key: day_key)
      days[day_key] = day&.to_schedule_hash || default_day_schedule
    end

    days
  end

  def to_frontend_json
    {
      id: week_id,
      startDate: start_date.iso8601,
      weeklyTips: weekly_tips.to_f,
      schedule: schedule
    }
  end

  def calculate_totals
    # Recalcular totales basados en los días
    self.total_hours = payroll_days.sum(:hours_worked)
    self.total_regular_hours = payroll_days.sum(:regular_hours)
    self.total_overtime_hours = payroll_days.sum(:overtime_hours)
    self.total_extra_hours = payroll_days.sum(:extra_hours)
    self.total_base_pay = payroll_days.sum(:daily_pay)
    self.total_pay = total_base_pay + (weekly_tips || 0)
    self.total_shifts = payroll_days.where(is_working: true).count
  end

  def recalculate_and_save!
    payroll_days.each(&:calculate_day_totals!)
    calculate_totals
    save!
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, 'debe ser posterior a la fecha de inicio')
    end
  end

  def build_days
    return if payroll_days.any?

    day_keys = %w[monday tuesday wednesday thursday friday saturday sunday]
    current_date = start_date

    day_keys.each do |day_key|
      payroll_days.build(
        day_key: day_key,
        date: current_date,
        is_working: false
      )
      current_date += 1.day
    end
  end

  def default_day_schedule
    {
      entryHour: nil,
      entryMinute: nil,
      exitHour: nil,
      exitMinute: nil,
      hoursWorked: 0,
      regularHours: 0,
      overtimeHours: 0,
      extraHours: 0,
      dailyPay: 0,
      isWorking: false
    }
  end
end
