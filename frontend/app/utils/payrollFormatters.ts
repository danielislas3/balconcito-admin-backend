/**
 * Funciones de formateo para el módulo de nóminas
 *
 * Este archivo contiene utilidades para formatear datos relacionados con nóminas,
 * como monedas, fechas y horarios.
 */

import { CURRENCY_SYMBOLS, type Currency } from './payrollConstants'

/**
 * Formatea una cantidad de dinero con el símbolo de moneda apropiado
 *
 * @param amount - Cantidad a formatear
 * @param currency - Código de moneda (MXN, USD, EUR)
 * @returns String formateado con símbolo de moneda
 *
 * @example
 * formatCurrency(1500, 'MXN') // "$1500.00"
 * formatCurrency(25.5, 'USD') // "$25.50"
 */
export const formatCurrency = (amount: number, currency: Currency = 'MXN'): string => {
  const symbol = CURRENCY_SYMBOLS[currency] || '$'
  return `${symbol}${amount.toFixed(2)}`
}

/**
 * Formatea una fecha para mostrar en formato DD/MM/YYYY
 *
 * @param dateStr - String de fecha en formato ISO
 * @returns Fecha formateada
 *
 * @example
 * formatWeekDisplay('2025-01-13') // "13/01/2025"
 */
export const formatWeekDisplay = (dateStr: string): string => {
  const dayjs = useDayjs()
  return dayjs(dateStr).format('DD/MM/YYYY')
}

/**
 * Formatea una fecha para mostrar el mes completo
 *
 * @param dateStr - String de fecha en formato ISO
 * @returns Mes y año formateados
 *
 * @example
 * formatMonthDisplay('2025-01-13') // "enero 2025"
 */
export const formatMonthDisplay = (dateStr: string): string => {
  const dayjs = useDayjs()
  return dayjs(dateStr).format('MMMM YYYY')
}

/**
 * Formatea un horario (hora:minuto)
 *
 * @param hour - Hora (00-23)
 * @param minute - Minuto (00-59)
 * @returns Horario formateado o placeholder
 *
 * @example
 * formatTime('09', '30') // "09:30"
 * formatTime('', '') // "--:--"
 */
export const formatTime = (hour: string, minute: string): string => {
  if (!hour || !minute) return '--:--'
  return `${hour}:${minute}`
}

/**
 * Formatea horas trabajadas con un decimal
 *
 * @param hours - Horas a formatear
 * @returns Horas formateadas con "h"
 *
 * @example
 * formatHours(8.5) // "8.5h"
 * formatHours(0) // "0.0h"
 */
export const formatHours = (hours: number): string => {
  return `${hours.toFixed(1)}h`
}
