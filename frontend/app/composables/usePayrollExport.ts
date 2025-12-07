/**
 * Composable para exportar datos de nóminas
 *
 * Proporciona funciones para exportar reportes de nóminas en formato de texto,
 * incluyendo reportes generales de todos los empleados y reportes individuales.
 */

import type { PayrollEmployee, WeekSchedule } from '~/types/payroll'
import { CURRENCY_SYMBOLS, WEEK_DAYS } from '~/utils/payrollConstants'
import { formatWeekDisplay } from '~/utils/payrollFormatters'
import { calculateEmployeeStats, calculateWeekTotals } from '~/utils/payrollCalculations'

export const usePayrollExport = () => {
  const dayjs = useDayjs()

  /**
   * Descarga un archivo de texto
   */
  const downloadTextFile = (content: string, filename: string) => {
    const blob = new Blob([content], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  /**
   * Exporta un reporte general de todos los empleados
   *
   * @param employees - Lista de empleados a exportar
   */
  const exportAllEmployees = (employees: PayrollEmployee[]): void => {
    let exportText = `=== REPORTE GENERAL DE NÓMINAS ===\n`
    exportText += `Fecha de exportación: ${dayjs().format('DD/MM/YYYY')}\n`
    exportText += `Total de empleados: ${employees.length}\n\n`

    employees.forEach(employee => {
      const stats = calculateEmployeeStats(employee)
      const currency = CURRENCY_SYMBOLS[employee.settings.currency] || '$'

      exportText += `=== ${employee.name.toUpperCase()} ===\n`
      exportText += `Semanas registradas: ${stats.totalWeeks}\n`
      exportText += `Total de horas: ${stats.totalHours.toFixed(1)}\n`
      exportText += `Promedio horas/semana: ${stats.avgHoursPerWeek.toFixed(1)}\n`
      exportText += `PAGO TOTAL: ${currency}${stats.totalPay.toFixed(2)}\n\n`
    })

    const filename = `reporte_general_nominas_${dayjs().format('YYYY-MM-DD')}.txt`
    downloadTextFile(exportText, filename)
  }

  /**
   * Exporta un reporte detallado de un empleado específico
   *
   * @param employee - Empleado a exportar
   */
  const exportEmployeeData = (employee: PayrollEmployee): void => {
    const stats = calculateEmployeeStats(employee)
    const currency = CURRENCY_SYMBOLS[employee.settings.currency] || '$'

    let exportText = `=== REPORTE DE NÓMINA - ${employee.name.toUpperCase()} ===\n`
    exportText += `Tarifa por hora: ${currency}${employee.settings.baseHourlyRate}\n`
    exportText += `Moneda: ${employee.settings.currency}\n`
    exportText += `Fecha de exportación: ${dayjs().format('DD/MM/YYYY')}\n\n`

    exportText += `=== RESUMEN GENERAL ===\n`
    exportText += `Semanas registradas: ${stats.totalWeeks}\n`
    exportText += `Total de horas: ${stats.totalHours.toFixed(1)}\n`
    exportText += `Promedio horas/semana: ${stats.avgHoursPerWeek.toFixed(1)}\n`
    exportText += `PAGO TOTAL: ${currency}${stats.totalPay.toFixed(2)}\n\n`

    exportText += `=== DETALLE POR SEMANAS ===\n`

    // Ordenar semanas de más reciente a más antigua
    const sortedWeeks = [...employee.weeks].sort(
      (a, b) => dayjs(b.startDate).valueOf() - dayjs(a.startDate).valueOf()
    )

    sortedWeeks.forEach(week => {
      exportText += `\nSemana del ${formatWeekDisplay(week.startDate)}:\n`

      WEEK_DAYS.forEach(day => {
        const dayData = week.schedule[day.key as keyof WeekSchedule]
        if (dayData && dayData.hoursWorked > 0) {
          const entry = dayData.entryHour && dayData.entryMinute
            ? `${dayData.entryHour}:${dayData.entryMinute}`
            : '--:--'
          const exit = dayData.exitHour && dayData.exitMinute
            ? `${dayData.exitHour}:${dayData.exitMinute}`
            : '--:--'

          exportText += `  ${day.name}: ${entry} - ${exit} | ${dayData.hoursWorked.toFixed(1)}hrs | ${currency}${dayData.dailyPay.toFixed(2)}\n`
        }
      })

      if (week.weeklyTips > 0) {
        exportText += `  Propinas: ${currency}${week.weeklyTips.toFixed(2)}\n`
      }
    })

    const filename = `nomina_${employee.name.replace(/\s+/g, '_')}_${dayjs().format('YYYY-MM-DD')}.txt`
    downloadTextFile(exportText, filename)
  }

  return {
    exportAllEmployees,
    exportEmployeeData
  }
}
