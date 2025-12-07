/**
 * Funciones de cálculo para el módulo de nóminas
 *
 * Este archivo contiene todas las funciones de cálculo y agregación de datos
 * relacionados con nóminas. Los valores base vienen del backend ya calculados,
 * estas funciones solo los suman/agregan.
 */

import type { PayrollEmployee, PayrollWeek, WeekSchedule } from '~/types/payroll'
import { WEEK_DAYS } from './payrollConstants'

/**
 * Resultado de cálculos de totales semanales
 */
export interface WeekTotals {
  totalHours: number
  regularHours: number
  overtimeHours: number
  extraHours: number
  totalBasePay: number
  totalPay: number
}

/**
 * Calcula los totales de una semana sumando todos los días
 *
 * NOTA: Los valores diarios (hoursWorked, dailyPay, etc.) ya vienen
 * calculados desde el backend. Esta función solo los suma.
 *
 * @param week - Semana a calcular
 * @returns Totales de la semana
 */
export const calculateWeekTotals = (week: PayrollWeek): WeekTotals => {
  const totals = WEEK_DAYS.reduce((acc, day) => {
    const dayData = week.schedule?.[day.key as keyof WeekSchedule]
    if (!dayData) return acc

    acc.totalHours += dayData.hoursWorked || 0
    acc.regularHours += dayData.regularHours || 0
    acc.overtimeHours += dayData.overtimeHours || 0
    acc.extraHours += dayData.extraHours || 0
    acc.totalBasePay += dayData.dailyPay || 0

    return acc
  }, {
    totalHours: 0,
    regularHours: 0,
    overtimeHours: 0,
    extraHours: 0,
    totalBasePay: 0
  })

  const weeklyTips = week.weeklyTips || 0
  const totalPay = totals.totalBasePay + weeklyTips

  return { ...totals, totalPay }
}

/**
 * Resultado de cálculos de estadísticas de empleado
 */
export interface EmployeeStats {
  totalWeeks: number
  totalHours: number
  totalPay: number
  avgHoursPerWeek: number
}

/**
 * Calcula estadísticas generales de un empleado
 *
 * @param employee - Empleado a analizar
 * @returns Estadísticas del empleado
 */
export const calculateEmployeeStats = (employee: PayrollEmployee): EmployeeStats => {
  const totalWeeks = employee.weeks.length
  let totalHours = 0
  let totalPay = 0

  employee.weeks.forEach(week => {
    const weekTotals = calculateWeekTotals(week)
    totalHours += weekTotals.totalHours
    totalPay += weekTotals.totalPay
  })

  return {
    totalWeeks,
    totalHours,
    totalPay,
    avgHoursPerWeek: totalWeeks > 0 ? (totalHours / totalWeeks) : 0
  }
}

/**
 * Resultado de cálculos mensuales
 */
export interface MonthlyStats {
  year: number
  month: number
  weeksCount: number
  weeks: PayrollWeek[]
  totalHours: number
  regularHours: number
  overtimeHours: number
  extraHours: number
  totalTips: number
  totalBasePay: number
  totalPay: number
  avgHoursPerWeek: number
  avgPayPerWeek: number
}

/**
 * Calcula estadísticas de un mes específico para un empleado
 *
 * @param employee - Empleado a analizar
 * @param year - Año a consultar
 * @param month - Mes a consultar (0-11)
 * @returns Estadísticas mensuales o null si no hay datos
 */
export const calculateMonthlyStats = (
  employee: PayrollEmployee,
  year: number,
  month: number
): MonthlyStats | null => {
  const dayjs = useDayjs()

  const weeksInMonth = employee.weeks.filter(week => {
    const weekDate = dayjs(week.startDate)
    return weekDate.year() === year && weekDate.month() === month
  })

  if (weeksInMonth.length === 0) return null

  const monthlyTotals = weeksInMonth.reduce((totals, week) => {
    const weekTotals = calculateWeekTotals(week)

    totals.totalHours += weekTotals.totalHours
    totals.regularHours += weekTotals.regularHours
    totals.overtimeHours += weekTotals.overtimeHours
    totals.extraHours += weekTotals.extraHours
    totals.totalTips += week.weeklyTips || 0
    totals.totalBasePay += weekTotals.totalBasePay
    totals.totalPay += weekTotals.totalPay

    return totals
  }, {
    totalHours: 0,
    regularHours: 0,
    overtimeHours: 0,
    extraHours: 0,
    totalTips: 0,
    totalBasePay: 0,
    totalPay: 0
  })

  return {
    year,
    month,
    weeksCount: weeksInMonth.length,
    weeks: weeksInMonth,
    avgHoursPerWeek: monthlyTotals.totalHours / weeksInMonth.length,
    avgPayPerWeek: monthlyTotals.totalPay / weeksInMonth.length,
    ...monthlyTotals
  }
}

/**
 * Información de un mes disponible
 */
export interface AvailableMonth {
  year: number
  month: number
  label: string
}

/**
 * Obtiene la lista de meses que tienen datos para un empleado
 *
 * @param employee - Empleado a analizar
 * @returns Lista de meses disponibles ordenados de más reciente a más antiguo
 */
export const getAvailableMonths = (employee: PayrollEmployee): AvailableMonth[] => {
  if (!employee || employee.weeks.length === 0) return []

  const dayjs = useDayjs()
  const monthsSet = new Set<string>()

  employee.weeks.forEach(week => {
    const date = dayjs(week.startDate)
    const key = `${date.year()}-${date.month()}`
    monthsSet.add(key)
  })

  const months = Array.from(monthsSet).map(key => {
    const [year, month] = key.split('-').map(Number)
    const date = dayjs().year(year).month(month)
    const label = date.format('MMMM YYYY')
    return { year, month, label }
  })

  // Ordenar de más reciente a más antiguo
  months.sort((a, b) => {
    if (a.year !== b.year) return b.year - a.year
    return b.month - a.month
  })

  return months
}
