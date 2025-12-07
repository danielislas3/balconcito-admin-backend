/**
 * Constantes utilizadas en el módulo de nóminas
 *
 * Este archivo centraliza todas las constantes relacionadas con el sistema de nóminas,
 * incluyendo símbolos de moneda, días de la semana y otras configuraciones.
 */

/**
 * Símbolos de moneda por código ISO
 */
export const CURRENCY_SYMBOLS = {
  MXN: '$',
  USD: '$',
  EUR: '€'
} as const

export type Currency = keyof typeof CURRENCY_SYMBOLS

/**
 * Días de la semana con sus respectivos nombres en español y emojis
 */
export const WEEK_DAYS = [
  { key: 'monday', name: 'Lunes', emoji: '📅' },
  { key: 'tuesday', name: 'Martes', emoji: '📊' },
  { key: 'wednesday', name: 'Miércoles', emoji: '📈' },
  { key: 'thursday', name: 'Jueves', emoji: '📋' },
  { key: 'friday', name: 'Viernes', emoji: '📌' },
  { key: 'saturday', name: 'Sábado', emoji: '🎯' },
  { key: 'sunday', name: 'Domingo', emoji: '✨' }
] as const

export type WeekDayKey = typeof WEEK_DAYS[number]['key']

/**
 * Array de horas (00-23) formateadas con ceros a la izquierda
 */
export const HOURS = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))

/**
 * Minutos comunes para selectores
 */
export const MINUTES = ['00', '15', '30', '45'] as const
