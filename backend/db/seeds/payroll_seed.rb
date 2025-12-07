# frozen_string_literal: true

# Seeder para datos de nómina desde sistema Vue anterior
# Basado en: /Users/danielorio/Desktop/sistema_nomina_vue_2025-12-01.json

puts "🚀 Iniciando seeder de nómina..."

# Mapeo de días español → inglés
DAY_MAPPING = {
  'lunes' => 'monday',
  'martes' => 'tuesday',
  'miercoles' => 'wednesday',
  'jueves' => 'thursday',
  'viernes' => 'friday',
  'sabado' => 'saturday',
  'domingo' => 'sunday'
}.freeze

# Datos de empleados
employees_data = [
  {
    id: 'mfuhe110g53deou1cy4',
    name: 'Juan Pérez',
    cost_per_turn: 450,
    currency: 'MXN',
    weeks: []
  },
  {
    id: 'mg22pnkykhs5pvh2dxb',
    name: 'David.',
    cost_per_turn: 335,
    currency: 'MXN',
    weeks: [
      {
        id: 'mg22qp9ef2boz3lbnae',
        start_date: '2025-09-22',
        weekly_tips: 90,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '00', exitMinute: '15' },
          'martes' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '45' },
          'miercoles' => { entryHour: '15', entryMinute: '45', exitHour: '00', exitMinute: '00' },
          'jueves' => { entryHour: '15', entryMinute: '00', exitHour: '01', exitMinute: '30' },
          'viernes' => { entryHour: '16', entryMinute: '15', exitHour: '04', exitMinute: '45' },
          'sabado' => { entryHour: '14', entryMinute: '00', exitHour: '03', exitMinute: '00' },
          'domingo' => { entryHour: '16', entryMinute: '00', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mgyfsuynh44nmbl2xja',
        start_date: '2025-10-14',
        weekly_tips: 440,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '03', exitMinute: '45' },
          'martes' => { entryHour: '18', entryMinute: '45', exitHour: '01', exitMinute: '15' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '30' },
          'jueves' => { entryHour: '15', entryMinute: '45', exitHour: '02', exitMinute: '30' },
          'viernes' => { entryHour: '16', entryMinute: '00', exitHour: '01', exitMinute: '15' },
          'sabado' => { entryHour: '16', entryMinute: '15', exitHour: '05', exitMinute: '30' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mh8empflq8l9rm5qjz',
        start_date: '2025-10-21',
        weekly_tips: 255,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '02', exitMinute: '15' },
          'martes' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '15' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '15' },
          'jueves' => { entryHour: '16', entryMinute: '30', exitHour: '01', exitMinute: '30' },
          'viernes' => { entryHour: '16', entryMinute: '00', exitHour: '04', exitMinute: '00' },
          'sabado' => { entryHour: '16', entryMinute: '30', exitHour: '03', exitMinute: '30' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mhsgo32lm0q9g9jgejn',
        start_date: '2025-11-04',
        weekly_tips: 567,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '04', exitMinute: '00' },
          'martes' => { entryHour: '16', entryMinute: '15', exitHour: '23', exitMinute: '15' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '30' },
          'jueves' => { entryHour: '16', entryMinute: '00', exitHour: '01', exitMinute: '00' },
          'viernes' => { entryHour: '16', entryMinute: '00', exitHour: '03', exitMinute: '00' },
          'sabado' => { entryHour: '16', entryMinute: '15', exitHour: '05', exitMinute: '15' },
          'domingo' => { entryHour: '16', entryMinute: '00', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'micgcx2x4uk5tkq41lt',
        start_date: '2025-11-18',
        weekly_tips: 475,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '02', exitMinute: '15' },
          'martes' => { entryHour: '16', entryMinute: '00', exitHour: '04', exitMinute: '30' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '30' },
          'jueves' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '00' },
          'viernes' => { entryHour: '17', entryMinute: '00', exitHour: '04', exitMinute: '30' },
          'sabado' => { entryHour: '16', entryMinute: '30', exitHour: '04', exitMinute: '00' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mimi559gis0hh98xsf',
        start_date: '2025-11-25',
        weekly_tips: 175,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '00', exitMinute: '30' },
          'martes' => { entryHour: '16', entryMinute: '00', exitHour: '00', exitMinute: '30' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '22', exitMinute: '00' },
          'jueves' => { entryHour: '16', entryMinute: '00', exitHour: '02', exitMinute: '30' },
          'viernes' => { entryHour: '16', entryMinute: '00', exitHour: '05', exitMinute: '00' },
          'sabado' => { entryHour: '16', entryMinute: '15', exitHour: '05', exitMinute: '00' },
          'domingo' => { entryHour: '15', entryMinute: '30', exitHour: '00', exitMinute: '00' }
        }
      }
    ]
  },
  {
    id: 'mg4fuf8j9upmkqpumqm',
    name: 'Ani',
    cost_per_turn: 200,
    currency: 'MXN',
    weeks: [
      {
        id: 'mg4fuiai68ec1tup8go',
        start_date: '2025-09-23',
        weekly_tips: 0,
        schedule: {
          'sabado' => { entryHour: '17', entryMinute: '45', exitHour: '03', exitMinute: '00' }
        }
      },
      {
        id: 'mgyfebjpykrv6mnnyuk',
        start_date: '2025-10-14',
        weekly_tips: 0,
        schedule: {
          'viernes' => { entryHour: '17', entryMinute: '15', exitHour: '01', exitMinute: '15' },
          'sabado' => { entryHour: '16', entryMinute: '15', exitHour: '05', exitMinute: '30' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mh8f1s7rthn2qvguvqm',
        start_date: '2025-10-21',
        weekly_tips: 255,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '02', exitMinute: '15' },
          'martes' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '15' },
          'miercoles' => { entryHour: '16', entryMinute: '15', exitHour: '01', exitMinute: '15' },
          'jueves' => { entryHour: '16', entryMinute: '30', exitHour: '01', exitMinute: '30' },
          'viernes' => { entryHour: '16', entryMinute: '00', exitHour: '04', exitMinute: '00' },
          'sabado' => { entryHour: '16', entryMinute: '30', exitHour: '03', exitMinute: '30' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      }
    ]
  },
  {
    id: 'micgwrlorjpft2jupzn',
    name: 'Yahir',
    cost_per_turn: 300,
    currency: 'MXN',
    weeks: [
      {
        id: 'micgwycldn3qczf7v4w',
        start_date: '2025-11-18',
        weekly_tips: 170,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '01', exitMinute: '15' },
          'jueves' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '45' },
          'viernes' => { entryHour: '16', entryMinute: '15', exitHour: '04', exitMinute: '30' },
          'sabado' => { entryHour: '17', entryMinute: '15', exitHour: '01', exitMinute: '00' },
          'domingo' => { entryHour: '16', entryMinute: '15', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mimibzqvqzstnefwn88',
        start_date: '2025-11-25',
        weekly_tips: 175,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '00', exitMinute: '30' },
          'jueves' => { entryHour: '16', entryMinute: '15', exitHour: '22', exitMinute: '00' },
          'viernes' => { entryHour: '16', entryMinute: '30', exitHour: '01', exitMinute: '15' },
          'sabado' => { entryHour: '16', entryMinute: '30', exitHour: '02', exitMinute: '30' },
          'domingo' => { entryHour: '16', entryMinute: '00', exitHour: '00', exitMinute: '00' }
        }
      }
    ]
  },
  {
    id: 'michguxaoc3ctmbh9ic',
    name: 'Carlos',
    cost_per_turn: 300,
    currency: 'MXN',
    weeks: [
      {
        id: 'michh122k6c1yg899sc',
        start_date: '2025-11-18',
        weekly_tips: 170,
        schedule: {
          'jueves' => { entryHour: '16', entryMinute: '30', exitHour: '00', exitMinute: '45' },
          'viernes' => { entryHour: '17', entryMinute: '15', exitHour: '04', exitMinute: '00' },
          'sabado' => { entryHour: '17', entryMinute: '15', exitHour: '03', exitMinute: '00' },
          'domingo' => { entryHour: '17', entryMinute: '00', exitHour: '00', exitMinute: '00' }
        }
      },
      {
        id: 'mimihyqw3xgl04820hx',
        start_date: '2025-11-25',
        weekly_tips: 175,
        schedule: {
          'lunes' => { entryHour: '00', entryMinute: '00', exitHour: '00', exitMinute: '30' },
          'martes' => { entryHour: '17', entryMinute: '00', exitHour: '00', exitMinute: '30' },
          'miercoles' => { entryHour: '17', entryMinute: '00', exitHour: '22', exitMinute: '00' },
          'viernes' => { entryHour: '17', entryMinute: '00', exitHour: '02', exitMinute: '30' },
          'sabado' => { entryHour: '17', entryMinute: '00', exitHour: '01', exitMinute: '45' },
          'domingo' => { entryHour: '17', entryMinute: '00', exitHour: '00', exitMinute: '00' }
        }
      }
    ]
  }
]

# Función helper para crear días con horarios
def create_week_with_schedule(employee, week_data)
  start_date = Date.parse(week_data[:start_date])
  end_date = start_date + 6.days
  week_id = "#{start_date.year}-W#{start_date.cweek.to_s.rjust(2, '0')}"

  week = employee.payroll_weeks.create!(
    week_id: week_id,
    start_date: start_date,
    end_date: end_date,
    weekly_tips: week_data[:weekly_tips]
  )

  # Mapear días y crear horarios
  current_date = start_date
  %w[lunes martes miercoles jueves viernes sabado domingo].each do |spanish_day|
    english_day = DAY_MAPPING[spanish_day]
    day_schedule = week_data[:schedule][spanish_day]

    day = week.payroll_days.find_or_create_by!(day_key: english_day) do |d|
      d.date = current_date
    end

    if day_schedule && day_schedule[:entryHour].present?
      # Actualizar horario usando el método update_schedule
      day.update_schedule({
        entryHour: day_schedule[:entryHour],
        entryMinute: day_schedule[:entryMinute],
        exitHour: day_schedule[:exitHour],
        exitMinute: day_schedule[:exitMinute],
        isWorking: true
      })
    else
      # Día sin trabajar
      day.update!(is_working: false)
    end

    current_date += 1.day
  end

  # Recalcular totales de la semana
  week.recalculate_and_save!
  week
end

# Crear empleados y semanas
ActiveRecord::Base.transaction do
  employees_data.each do |emp_data|
    puts "\n📝 Creando empleado: #{emp_data[:name]}"

    # Calcular base_hourly_rate desde cost_per_turn
    # cost_per_turn es el pago por 8 horas (HOURS_PER_SHIFT)
    base_hourly_rate = emp_data[:cost_per_turn] / 8.0

    employee = PayrollEmployee.find_or_initialize_by(employee_id: emp_data[:id]) do |e|
      e.name = emp_data[:name]
      e.base_hourly_rate = base_hourly_rate
      e.currency = emp_data[:currency]
    end

    if employee.new_record?
      employee.save!
      puts "   ✅ Empleado creado: #{employee.name} (rate: $#{base_hourly_rate}/hr)"
    else
      puts "   ⏭️  Empleado ya existe: #{employee.name}"
    end

    # Crear semanas
    emp_data[:weeks].each do |week_data|
      week_id = "#{Date.parse(week_data[:start_date]).year}-W#{Date.parse(week_data[:start_date]).cweek.to_s.rjust(2, '0')}"

      if employee.payroll_weeks.exists?(week_id: week_id)
        puts "   ⏭️  Semana #{week_id} ya existe"
        next
      end

      week = create_week_with_schedule(employee, week_data)
      puts "   ✅ Semana #{week.week_id} creada (#{week.total_shifts} turnos, $#{week.total_pay.round(2)})"
    end
  end
end

puts "\n✨ Seeder completado!"
puts "\n📊 Resumen:"
puts "   Empleados: #{PayrollEmployee.count}"
puts "   Semanas: #{PayrollWeek.count}"
puts "   Días trabajados: #{PayrollDay.where(is_working: true).count}"
