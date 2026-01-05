# frozen_string_literal: true

# Servicio para centralizar toda la lógica de cálculos de nómina
# Este servicio es la única fuente de verdad para calcular:
# - Horas trabajadas (con lógica de descanso)
# - Horas regulares vs overtime
# - Pago diario y semanal
class PayrollCalculator
  attr_reader :employee, :settings, :custom_hourly_rate

  def initialize(employee, custom_shift_rate: nil)
    @employee = employee
    @settings = employee.settings

    # Si se proporciona un shift_rate personalizado, calcular la tarifa horaria equivalente
    if custom_shift_rate&.positive?
      hours_per_shift = @settings[:hoursPerShift] || 8
      @custom_hourly_rate = custom_shift_rate / hours_per_shift.to_f
    else
      @custom_hourly_rate = nil
    end
  end

  # Obtener la tarifa horaria a usar (personalizada o del empleado)
  def hourly_rate
    @custom_hourly_rate || employee.base_hourly_rate
  end

  # Calcula las horas trabajadas considerando el descanso obligatorio
  # Lógica: Si trabajaste >= min_hours_for_break horas, se resta break_hours
  # Si se proporciona custom_break_hours, lo usa en vez del default
  def calculate_worked_hours(total_hours_in_place, custom_break_hours: nil)
    return 0 if total_hours_in_place <= 0

    if total_hours_in_place >= settings[:minHoursForBreak]
      break_to_apply = custom_break_hours || settings[:breakHours]
      total_hours_in_place - break_to_apply
    else
      total_hours_in_place
    end
  end

  # Calcula horas en el lugar de trabajo (entrada -> salida)
  # Maneja cruce de medianoche (salida < entrada)
  def calculate_hours_in_place(entry_hour, entry_minute, exit_hour, exit_minute)
    return 0 unless entry_hour && entry_minute && exit_hour && exit_minute

    entry_time = entry_hour.to_i + (entry_minute.to_i / 60.0)
    exit_time = exit_hour.to_i + (exit_minute.to_i / 60.0)

    # Si la salida es menor que la entrada, significa que cruzó medianoche
    exit_time += 24 if exit_time <= entry_time

    exit_time - entry_time
  end

  # Calcula la distribución de horas: regular, tier1 overtime, tier2 overtime
  # Umbral global de 20 minutos: solo cuenta overtime si supera este mínimo
  def calculate_hour_distribution(worked_hours, force_overtime: false, entry_hour: nil, entry_minute: nil, exit_hour: nil, exit_minute: nil)
    return { regular: worked_hours, overtime_tier1: 0, overtime_tier2: 0 } unless worked_hours > 0

    # Si force_overtime está activo, usar lógica especial para lunes (después de 1 AM)
    if force_overtime
      return calculate_force_overtime_distribution(entry_hour, entry_minute, exit_hour, exit_minute, worked_hours)
    end

    # Si no usa overtime o no excedió las horas del turno, todo es regular
    unless settings[:usesOvertime] && worked_hours > settings[:hoursPerShift]
      return { regular: worked_hours, overtime_tier1: 0, overtime_tier2: 0 }
    end

    # Calcular horas extras
    regular_hours = settings[:hoursPerShift]
    total_extra = worked_hours - regular_hours

    # Umbral mínimo de 20 minutos: solo cuenta overtime si supera este tiempo
    # Esto evita que empleados "hagan tiempo" 10-15 minutos para cobrar extra
    if total_extra < (20.0 / 60.0)
      # Menos de 20 min de overtime, no cuenta (se pierden o se pagan como regular)
      return { regular: worked_hours, overtime_tier1: 0, overtime_tier2: 0 }
    end

    # Tier 1: Primeras N horas extras (ej: 2 horas al 150%)
    tier1_hours = [ total_extra, settings[:overtimeTier1Hours] ].min

    # Tier 2: Resto de horas extras (al 200%)
    tier2_hours = [ total_extra - tier1_hours, 0 ].max

    {
      regular: regular_hours,
      overtime_tier1: tier1_hours,
      overtime_tier2: tier2_hours
    }
  end

  # Distribución especial para force_overtime: horas antes de 1 AM = regular, después = overtime
  # Con umbral mínimo de 20 minutos: solo cuenta overtime si excede 1:20 AM
  def calculate_force_overtime_distribution(entry_hour, entry_minute, exit_hour, exit_minute, worked_hours)
    return { regular: 0, overtime_tier1: 0, overtime_tier2: 0 } unless worked_hours > 0

    # Convertir a tiempo decimal
    entry_time = entry_hour.to_i + (entry_minute.to_i / 60.0)
    exit_time = exit_hour.to_i + (exit_minute.to_i / 60.0)

    # Manejar cruce de medianoche
    exit_time += 24 if exit_time <= entry_time

    # Umbral base: 1:00 AM
    base_threshold = 1.0
    # Umbral mínimo para overtime: 20 minutos = 0.333 horas
    # Solo cuenta overtime si sale después de 1:20 AM
    overtime_threshold = base_threshold + (20.0 / 60.0)  # 1.333 (1:20 AM)

    # Calcular horas en el lugar (sin descanso)
    total_hours_in_place = exit_time - entry_time

    # Calcular distribución según los umbrales
    if exit_time <= overtime_threshold
      # Si sale antes de 1:20 AM, no hay overtime (todo regular o se pierde)
      regular_hours = worked_hours
      overtime_hours = 0
    elsif entry_time >= base_threshold
      # Si empieza después de la 1 AM, verificar si cumple umbral mínimo
      time_after_threshold = exit_time - base_threshold
      if time_after_threshold >= (20.0 / 60.0)
        # Supera el umbral de 20 min, todas son overtime
        regular_hours = 0
        overtime_hours = worked_hours
      else
        # No supera umbral, todas regulares
        regular_hours = worked_hours
        overtime_hours = 0
      end
    else
      # Cruza el umbral de 1 AM: calcular proporción
      hours_before_threshold = base_threshold - entry_time
      hours_after_threshold = exit_time - base_threshold

      # Solo cuenta overtime si el tiempo después de 1 AM supera 20 minutos
      if hours_after_threshold >= (20.0 / 60.0)
        # Aplicar la misma proporción de descanso a ambos segmentos
        if worked_hours < total_hours_in_place
          # Hubo descanso, distribuir proporcionalmente
          ratio = worked_hours / total_hours_in_place
          regular_hours = hours_before_threshold * ratio
          overtime_hours = hours_after_threshold * ratio
        else
          # No hubo descanso
          regular_hours = hours_before_threshold
          overtime_hours = hours_after_threshold
        end
      else
        # No supera el umbral de 20 min, todo es regular
        regular_hours = worked_hours
        overtime_hours = 0
      end
    end

    {
      regular: regular_hours.round(2),
      overtime_tier1: overtime_hours.round(2),
      overtime_tier2: 0
    }
  end

  # Calcula el pago diario basado en la distribución de horas
  def calculate_daily_pay(hour_distribution)
    base_rate = hourly_rate  # Usar la tarifa horaria (personalizada o del empleado)

    regular_pay = hour_distribution[:regular] * base_rate
    overtime_tier1_pay = hour_distribution[:overtime_tier1] * base_rate * settings[:overtimeTier1Rate]
    overtime_tier2_pay = hour_distribution[:overtime_tier2] * base_rate * settings[:overtimeTier2Rate]

    regular_pay + overtime_tier1_pay + overtime_tier2_pay
  end

  # Calcula todos los valores de un día en una sola operación
  # Retorna un hash con todos los valores calculados
  def calculate_day(entry_hour:, entry_minute:, exit_hour:, exit_minute:, is_working: true, force_overtime: false, custom_break_hours: nil)
    return reset_day_values unless is_working

    # 1. Calcular horas en el lugar
    total_hours_in_place = calculate_hours_in_place(entry_hour, entry_minute, exit_hour, exit_minute)

    # 2. Aplicar lógica de descanso (personalizado o default)
    worked_hours = calculate_worked_hours(total_hours_in_place, custom_break_hours: custom_break_hours)

    # 3. Distribuir horas (regular, tier1, tier2)
    distribution = calculate_hour_distribution(
      worked_hours,
      force_overtime: force_overtime,
      entry_hour: entry_hour,
      entry_minute: entry_minute,
      exit_hour: exit_hour,
      exit_minute: exit_minute
    )

    # 4. Calcular pago
    daily_pay = calculate_daily_pay(distribution)

    {
      hours_worked: worked_hours.round(2),
      regular_hours: distribution[:regular].round(2),
      overtime_hours: distribution[:overtime_tier1].round(2),
      extra_hours: distribution[:overtime_tier2].round(2),
      daily_pay: daily_pay.round(2)
    }
  end

  # Calcula los totales de una semana basándose en los días
  def calculate_week_totals(payroll_days, weekly_tips: 0)
    total_hours = 0
    total_regular_hours = 0
    total_overtime_hours = 0
    total_extra_hours = 0
    total_base_pay = 0
    total_shifts = 0

    payroll_days.each do |day|
      next unless day.is_working

      total_hours += day.hours_worked || 0
      total_regular_hours += day.regular_hours || 0
      total_overtime_hours += day.overtime_hours || 0
      total_extra_hours += day.extra_hours || 0
      total_base_pay += day.daily_pay || 0
      total_shifts += 1
    end

    {
      total_hours: total_hours.round(2),
      total_regular_hours: total_regular_hours.round(2),
      total_overtime_hours: total_overtime_hours.round(2),
      total_extra_hours: total_extra_hours.round(2),
      total_base_pay: total_base_pay.round(2),
      total_pay: (total_base_pay + (weekly_tips || 0)).round(2),
      total_shifts: total_shifts
    }
  end

  private

  # Valores por defecto cuando no está trabajando
  def reset_day_values
    {
      hours_worked: 0,
      regular_hours: 0,
      overtime_hours: 0,
      extra_hours: 0,
      daily_pay: 0
    }
  end
end
