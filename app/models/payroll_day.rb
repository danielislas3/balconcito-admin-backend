class PayrollDay < ApplicationRecord
  # Associations
  belongs_to :payroll_week

  # Validations
  validates :day_key, presence: true, uniqueness: { scope: :payroll_week_id }
  validates :date, presence: true
  validates :hours_worked, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :calculate_day_totals, if: :schedule_changed?
  after_save :update_week_totals

  # Instance methods
  def to_schedule_hash
    {
      entryHour: entry_hour,
      entryMinute: entry_minute,
      exitHour: exit_hour,
      exitMinute: exit_minute,
      hoursWorked: hours_worked.to_f,
      regularHours: regular_hours.to_f,
      overtimeHours: overtime_hours.to_f,
      extraHours: extra_hours.to_f,
      dailyPay: daily_pay.to_f,
      isWorking: is_working
    }
  end

  def calculate_day_totals
    # Usar el servicio PayrollCalculator para todos los cálculos
    # Pasar shift_rate de la semana si existe
    calculator = PayrollCalculator.new(
      payroll_week.payroll_employee,
      custom_shift_rate: payroll_week.shift_rate
    )

    calculated_values = calculator.calculate_day(
      entry_hour: entry_hour,
      entry_minute: entry_minute,
      exit_hour: exit_hour,
      exit_minute: exit_minute,
      is_working: is_working
    )

    # Asignar valores calculados
    self.hours_worked = calculated_values[:hours_worked]
    self.regular_hours = calculated_values[:regular_hours]
    self.overtime_hours = calculated_values[:overtime_hours]
    self.extra_hours = calculated_values[:extra_hours]
    self.daily_pay = calculated_values[:daily_pay]
  end

  def calculate_day_totals!
    calculate_day_totals
    save!
  end

  def update_schedule(schedule_data)
    self.entry_hour = schedule_data[:entryHour]
    self.entry_minute = schedule_data[:entryMinute]
    self.exit_hour = schedule_data[:exitHour]
    self.exit_minute = schedule_data[:exitMinute]
    self.is_working = schedule_data[:isWorking] || has_complete_schedule?
    calculate_day_totals
    save
  end

  private

  def has_complete_schedule?
    entry_hour.present? && entry_minute.present? && exit_hour.present? && exit_minute.present?
  end

  def schedule_changed?
    entry_hour_changed? || entry_minute_changed? || exit_hour_changed? || exit_minute_changed? || is_working_changed?
  end

  def update_week_totals
    # Actualizar totales de la semana automáticamente después de guardar el día
    payroll_week.calculate_totals
    payroll_week.save! if payroll_week.changed?
  end
end
