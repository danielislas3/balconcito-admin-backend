// Tipos actualizados para coincidir con el backend

export interface DaySchedule {
  entryHour: string
  entryMinute: string
  exitHour: string
  exitMinute: string
  hoursWorked: number
  regularHours: number
  overtimeHours: number  // Tier 1 overtime
  extraHours: number     // Tier 2 overtime
  dailyPay: number
  isWorking: boolean
}

export interface WeekSchedule {
  monday: DaySchedule
  tuesday: DaySchedule
  wednesday: DaySchedule
  thursday: DaySchedule
  friday: DaySchedule
  saturday: DaySchedule
  sunday: DaySchedule
}

export interface PayrollWeek {
  id: string  // Format: YYYY-WXX
  startDate: string
  weeklyTips: number
  schedule: WeekSchedule
}

export interface EmployeeSettings {
  baseHourlyRate: number
  currency: 'MXN' | 'USD' | 'EUR'
  usesOvertime: boolean
  usesTips: boolean
  overtimeTier1Rate: number
  overtimeTier2Rate: number
  overtimeTier1Hours: number
  hoursPerShift: number
  breakHours: number
  minHoursForBreak: number
}

export interface PayrollEmployee {
  id: string
  name: string
  settings: EmployeeSettings
  weeks: PayrollWeek[]
}

// Helper types for API requests
export interface CreateEmployeeRequest {
  name: string
  base_hourly_rate: number
  currency: string
}

export interface CreateWeekRequest {
  start_date: string
  weekly_tips?: number
}

export interface UpdateScheduleRequest {
  schedule: Partial<Record<keyof WeekSchedule, Partial<DaySchedule>>>
}
