class PayrollDay < ApplicationRecord
  # Associations
  belongs_to :payroll_week

  # Validations
  validates :day_key, presence: true, uniqueness: { scope: :payroll_week_id }
  validates :date, presence: true
  validates :hours_worked, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Callbacks
  before_save :calculate_day_totals, if: :schedule_changed?

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
    # Si no está trabajando, resetear todo
    unless is_working
      self.hours_worked = 0
      self.regular_hours = 0
      self.overtime_hours = 0
      self.extra_hours = 0
      self.daily_pay = 0
      return
    end

    # Obtener configuración del empleado
    employee = payroll_week.payroll_employee
    settings = employee.settings

    # Calcular horas trabajadas
    total_hours_in_place = calculate_hours_in_place

    # Aplicar lógica de descanso
    worked_hours = if total_hours_in_place >= settings[:minHoursForBreak]
                     total_hours_in_place - settings[:breakHours]
                   else
                     total_hours_in_place
                   end

    self.hours_worked = worked_hours

    # Calcular horas regulares y extras
    if settings[:usesOvertime] && worked_hours > settings[:hoursPerShift]
      self.regular_hours = settings[:hoursPerShift]
      total_extra = worked_hours - settings[:hoursPerShift]

      # Calcular overtime tier 1 y tier 2
      tier1_hours = [total_extra, settings[:overtimeTier1Hours]].min
      tier2_hours = [total_extra - tier1_hours, 0].max

      self.overtime_hours = tier1_hours
      self.extra_hours = tier2_hours

      # Calcular pago
      regular_pay = regular_hours * employee.base_hourly_rate
      overtime_pay = overtime_hours * employee.base_hourly_rate * settings[:overtimeTier1Rate]
      extra_pay = extra_hours * employee.base_hourly_rate * settings[:overtimeTier2Rate]

      self.daily_pay = regular_pay + overtime_pay + extra_pay
    else
      # Sin overtime, todo es regular
      self.regular_hours = worked_hours
      self.overtime_hours = 0
      self.extra_hours = 0
      self.daily_pay = worked_hours * employee.base_hourly_rate
    end
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

  def calculate_hours_in_place
    return 0 unless entry_hour && entry_minute && exit_hour && exit_minute

    entry_time = entry_hour.to_i + (entry_minute.to_i / 60.0)
    exit_time = exit_hour.to_i + (exit_minute.to_i / 60.0)

    # Si la salida es menor que la entrada, significa que cruzó medianoche
    exit_time += 24 if exit_time <= entry_time

    exit_time - entry_time
  end

  def has_complete_schedule?
    entry_hour.present? && entry_minute.present? && exit_hour.present? && exit_minute.present?
  end

  def schedule_changed?
    entry_hour_changed? || entry_minute_changed? || exit_hour_changed? || exit_minute_changed? || is_working_changed?
  end
end
