import { defineStore } from 'pinia'
import type { PayrollEmployee, PayrollWeek, DaySchedule, WeekSchedule, EmployeeSettings } from '~/types/payroll'

// ===== LEGACY TYPES (for backwards compatibility with old localStorage data) =====
interface LegacyDaySchedule {
  entryHour: string
  entryMinute: string
  exitHour: string
  exitMinute: string
  hoursWorked?: number
  regularHours?: number
  overtimeHours1?: number
  overtimeHours2?: number
  completeShifts?: number
  extraHours?: number
  regularPay?: number
  overtimePay1?: number
  overtimePay2?: number
  dailyPay?: number
}

interface LegacyWeekSchedule {
  lunes?: LegacyDaySchedule
  martes?: LegacyDaySchedule
  miercoles?: LegacyDaySchedule
  jueves?: LegacyDaySchedule
  viernes?: LegacyDaySchedule
  sabado?: LegacyDaySchedule
  domingo?: LegacyDaySchedule
}

interface LegacyWeek {
  id: string
  startDate: string
  schedule?: LegacyWeekSchedule
  weeklyTips?: number
  saved?: boolean
}

interface LegacyEmployee {
  id: string
  name: string
  weeks?: LegacyWeek[]
  settings?: {
    costPerTurn?: number
    currency?: 'MXN' | 'USD' | 'EUR'
  }
}

interface LegacyPayrollSystemData {
  employees?: LegacyEmployee[]
  currentEmployeeId?: string
  currentWeekId?: string
  activeTab?: string
  version?: string
  weekTemplates?: any[]
}

export const usePayrollStore = defineStore('payroll', {
  state: () => ({
    employees: [] as PayrollEmployee[],
    currentEmployeeId: '',
    currentWeekId: '',
    activeTab: 'schedules' as string,
    loading: false,
    error: null as string | null,

    // UI Constants
    currencySymbols: { MXN: '$', USD: '$', EUR: '€' } as const,
    days: [
      { key: 'monday', name: 'Lunes', emoji: '📅' },
      { key: 'tuesday', name: 'Martes', emoji: '📊' },
      { key: 'wednesday', name: 'Miércoles', emoji: '📈' },
      { key: 'thursday', name: 'Jueves', emoji: '📋' },
      { key: 'friday', name: 'Viernes', emoji: '📌' },
      { key: 'saturday', name: 'Sábado', emoji: '🎯' },
      { key: 'sunday', name: 'Domingo', emoji: '✨' }
    ],
    hours: Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))
  }),

  getters: {
    currentEmployee: (state) => {
      return state.employees.find(emp => emp.id === state.currentEmployeeId) || null
    },

    currentEmployeeWeeks(): PayrollWeek[] {
      return this.currentEmployee?.weeks || []
    },

    currentWeek(): PayrollWeek | null {
      if (!this.currentEmployee || !this.currentWeekId) return null
      return this.currentEmployee.weeks.find(week => week.id === this.currentWeekId) || null
    },

    // Totals are now read-only from backend data
    weekTotals(): {
      totalHours: number
      regularHours: number
      overtimeHours: number  // Tier 1
      extraHours: number     // Tier 2
      totalBasePay: number
      totalPay: number
    } {
      if (!this.currentWeek) {
        return {
          totalHours: 0,
          regularHours: 0,
          overtimeHours: 0,
          extraHours: 0,
          totalBasePay: 0,
          totalPay: 0
        }
      }

      // Simply sum up values from backend-calculated schedule
      const totals = this.days.reduce((acc, day) => {
        const dayData = this.currentWeek!.schedule?.[day.key as keyof WeekSchedule]
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

      const weeklyTips = this.currentWeek.weeklyTips || 0
      const totalPay = totals.totalBasePay + weeklyTips

      return { ...totals, totalPay }
    },

    totalWeeks: (state) => {
      return state.employees.reduce((total, emp) => total + emp.weeks.length, 0)
    }
  },

  actions: {
    // ===== UTILITY ACTIONS =====
    formatCurrency(amount: number, currency: string | null = null): string {
      const curr = currency || this.currentEmployee?.settings?.currency || 'MXN'
      const symbol = this.currencySymbols[curr as keyof typeof this.currencySymbols] || '$'
      return `${symbol}${amount.toFixed(2)}`
    },

    formatWeekDisplay(dateStr: string): string {
      const dayjs = useDayjs()
      return dayjs(dateStr).format('DD/MM/YYYY')
    },

    // ===== API ACTIONS =====
    async fetchEmployees() {
      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        this.employees = await api.fetchEmployees()

        // Set current employee if not set or invalid
        if (!this.currentEmployeeId || !this.employees.find(e => e.id === this.currentEmployeeId)) {
          this.currentEmployeeId = this.employees.length > 0 ? this.employees[0].id : ''
        }
      } catch (error: any) {
        this.error = error?.message || 'Error al cargar empleados'
        console.error('Error fetching employees:', error)
      } finally {
        this.loading = false
      }
    },

    async createEmployee(name: string, baseHourlyRate: number, currency: string = 'MXN'): Promise<{ success: boolean; error?: string }> {
      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        const newEmployee = await api.createEmployee({
          name: name.trim(),
          base_hourly_rate: baseHourlyRate,
          currency
        })

        this.employees.push(newEmployee)
        this.currentEmployeeId = newEmployee.id
        this.currentWeekId = ''

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al crear empleado'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async updateEmployeeSettings(settings: Partial<EmployeeSettings>): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId) {
        return { success: false, error: 'No hay empleado seleccionado' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        const updatedEmployee = await api.updateEmployee(this.currentEmployeeId, { settings })

        // Update local state
        const index = this.employees.findIndex(e => e.id === this.currentEmployeeId)
        if (index !== -1) {
          this.employees[index] = updatedEmployee
        }

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al actualizar configuración'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async deleteCurrentEmployee(): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId) {
        return { success: false, error: 'No hay empleado seleccionado' }
      }

      if (this.employees.length <= 1) {
        return { success: false, error: 'No puedes eliminar el último empleado' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        await api.deleteEmployee(this.currentEmployeeId)

        // Remove from local state
        const index = this.employees.findIndex(e => e.id === this.currentEmployeeId)
        if (index !== -1) {
          this.employees.splice(index, 1)
        }

        // Select first employee
        this.currentEmployeeId = this.employees[0].id
        this.currentWeekId = ''

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al eliminar empleado'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    onEmployeeChange(): void {
      this.currentWeekId = ''
    },

    async createWeek(startDate: string, weeklyTips: number = 0): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId) {
        return { success: false, error: 'No hay empleado seleccionado' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        const newWeek = await api.createWeek(this.currentEmployeeId, {
          start_date: startDate,
          weekly_tips: weeklyTips
        })

        // Add to local state
        const employee = this.employees.find(e => e.id === this.currentEmployeeId)
        if (employee) {
          employee.weeks.push(newWeek)
          this.currentWeekId = newWeek.id
        }

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al crear semana'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async updateDaySchedule(dayKey: keyof WeekSchedule, schedule: Partial<DaySchedule>): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId || !this.currentWeekId) {
        return { success: false, error: 'No hay empleado o semana seleccionada' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()

        // IMPORTANT: Only send raw schedule data (entry/exit times, isWorking)
        // Backend will calculate all other values
        const rawSchedule = {
          entryHour: schedule.entryHour,
          entryMinute: schedule.entryMinute,
          exitHour: schedule.exitHour,
          exitMinute: schedule.exitMinute,
          isWorking: schedule.isWorking ?? true
        }

        const updatedWeek = await api.updateWeekSchedule(
          this.currentEmployeeId,
          this.currentWeekId,
          { [dayKey]: rawSchedule }
        )

        // Update local state with backend-calculated values
        const employee = this.employees.find(e => e.id === this.currentEmployeeId)
        if (employee) {
          const weekIndex = employee.weeks.findIndex(w => w.id === this.currentWeekId)
          if (weekIndex !== -1) {
            employee.weeks[weekIndex] = updatedWeek
          }
        }

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al actualizar horario'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async updateWeeklyTips(tips: number): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId || !this.currentWeekId) {
        return { success: false, error: 'No hay empleado o semana seleccionada' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        const updatedWeek = await api.updateWeek(
          this.currentEmployeeId,
          this.currentWeekId,
          { weekly_tips: tips }
        )

        // Update local state
        const employee = this.employees.find(e => e.id === this.currentEmployeeId)
        if (employee) {
          const weekIndex = employee.weeks.findIndex(w => w.id === this.currentWeekId)
          if (weekIndex !== -1) {
            employee.weeks[weekIndex] = updatedWeek
          }
        }

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al actualizar propinas'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async deleteCurrentWeek(): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId || !this.currentWeekId) {
        return { success: false, error: 'No hay empleado o semana seleccionada' }
      }

      this.loading = true
      this.error = null
      try {
        const api = usePayrollApi()
        await api.deleteWeek(this.currentEmployeeId, this.currentWeekId)

        // Remove from local state
        const employee = this.employees.find(e => e.id === this.currentEmployeeId)
        if (employee) {
          const weekIndex = employee.weeks.findIndex(w => w.id === this.currentWeekId)
          if (weekIndex !== -1) {
            employee.weeks.splice(weekIndex, 1)
          }
        }

        this.currentWeekId = ''

        return { success: true }
      } catch (error: any) {
        this.error = error?.message || 'Error al eliminar semana'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    // ===== REPORTS (read-only, based on backend data) =====
    calculateWeekTotals(week: PayrollWeek) {
      const totals = this.days.reduce((acc, day) => {
        const dayData = week.schedule[day.key as keyof WeekSchedule]
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
    },

    calculateEmployeeStats(employee: PayrollEmployee) {
      let totalWeeksCount = employee.weeks.length
      let totalHours = 0
      let totalPay = 0

      employee.weeks.forEach(week => {
        const weekTotals = this.calculateWeekTotals(week)
        totalHours += weekTotals.totalHours
        totalPay += weekTotals.totalPay
      })

      return {
        totalWeeks: totalWeeksCount,
        totalHours,
        totalPay,
        avgHoursPerWeek: totalWeeksCount > 0 ? (totalHours / totalWeeksCount) : 0
      }
    },

    // ===== MONTHLY CALCULATIONS =====
    calculateMonthlyStats(year: number, month: number) {
      const employee = this.currentEmployee
      if (!employee) return null

      const dayjs = useDayjs()
      const weeksInMonth = employee.weeks.filter(week => {
        const weekDate = dayjs(week.startDate)
        return weekDate.year() === year && weekDate.month() === month
      })

      if (weeksInMonth.length === 0) return null

      const monthlyTotals = weeksInMonth.reduce((totals, week) => {
        const weekTotals = this.calculateWeekTotals(week)

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
    },

    getAvailableMonths(): Array<{ year: number; month: number; label: string }> {
      const employee = this.currentEmployee
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

      months.sort((a, b) => {
        if (a.year !== b.year) return b.year - a.year
        return b.month - a.month
      })

      return months
    },

    // ===== EXPORT (client-side, uses backend data) =====
    exportAllEmployees(): void {
      const dayjs = useDayjs()
      let exportText = `=== REPORTE GENERAL DE NÓMINAS ===\n`
      exportText += `Fecha de exportación: ${dayjs().format('DD/MM/YYYY')}\n`
      exportText += `Total de empleados: ${this.employees.length}\n\n`

      this.employees.forEach(employee => {
        const stats = this.calculateEmployeeStats(employee)
        const currency = this.currencySymbols[employee.settings.currency] || '$'

        exportText += `=== ${employee.name.toUpperCase()} ===\n`
        exportText += `Semanas registradas: ${stats.totalWeeks}\n`
        exportText += `Total de horas: ${stats.totalHours.toFixed(1)}\n`
        exportText += `Promedio horas/semana: ${stats.avgHoursPerWeek.toFixed(1)}\n`
        exportText += `PAGO TOTAL: ${currency}${stats.totalPay.toFixed(2)}\n\n`
      })

      const blob = new Blob([exportText], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `reporte_general_nominas_${dayjs().format('YYYY-MM-DD')}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    },

    exportEmployeeData(employee: PayrollEmployee): void {
      const dayjs = useDayjs()
      const stats = this.calculateEmployeeStats(employee)
      const currency = this.currencySymbols[employee.settings.currency] || '$'

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
      employee.weeks.sort((a, b) => dayjs(b.startDate).valueOf() - dayjs(a.startDate).valueOf()).forEach(week => {
        exportText += `\nSemana del ${this.formatWeekDisplay(week.startDate)}:\n`

        this.days.forEach(day => {
          const dayData = week.schedule[day.key as keyof WeekSchedule]
          if (dayData.hoursWorked > 0) {
            const entry = dayData.entryHour && dayData.entryMinute ?
              `${dayData.entryHour}:${dayData.entryMinute}` : '--:--'
            const exit = dayData.exitHour && dayData.exitMinute ?
              `${dayData.exitHour}:${dayData.exitMinute}` : '--:--'

            exportText += `  ${day.name}: ${entry} - ${exit} | ${dayData.hoursWorked.toFixed(1)}hrs | ${currency}${dayData.dailyPay.toFixed(2)}\n`
          }
        })

        if (week.weeklyTips > 0) {
          exportText += `  Propinas: ${currency}${week.weeklyTips.toFixed(2)}\n`
        }
      })

      const blob = new Blob([exportText], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `nomina_${employee.name.replace(/\s+/g, '_')}_${dayjs().format('YYYY-MM-DD')}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    }
  }
})
