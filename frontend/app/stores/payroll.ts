import { defineStore } from 'pinia'

export interface DaySchedule {
  entryHour: string
  entryMinute: string
  exitHour: string
  exitMinute: string
  hoursWorked: number
  completeShifts: number
  extraHours: number
  dailyPay: number
}

export interface WeekSchedule {
  lunes: DaySchedule
  martes: DaySchedule
  miercoles: DaySchedule
  jueves: DaySchedule
  viernes: DaySchedule
  sabado: DaySchedule
  domingo: DaySchedule
}

export interface Week {
  id: string
  startDate: string
  schedule: WeekSchedule
  weeklyTips: number
  saved: boolean
}

export interface EmployeeSettings {
  costPerTurn: number
  currency: 'MXN' | 'USD' | 'EUR'
}

export interface Employee {
  id: string
  name: string
  weeks: Week[]
  settings: EmployeeSettings
}

export interface PayrollSystemData {
  employees: Employee[]
  currentEmployeeId: string
  currentWeekId: string
  activeTab: string
  version: string
}

const HOURS_PER_SHIFT = 9
const STORAGE_KEY = 'payrollSystemDataVue'

export const usePayrollStore = defineStore('payroll', {
  state: () => ({
    employees: [] as Employee[],
    currentEmployeeId: '',
    currentWeekId: '',
    activeTab: 'schedules' as string,

    // Constants
    currencySymbols: { MXN: '$', USD: '$', EUR: '€' } as const,
    days: [
      { key: 'lunes', name: 'Lunes', emoji: '📅' },
      { key: 'martes', name: 'Martes', emoji: '📊' },
      { key: 'miercoles', name: 'Miércoles', emoji: '📈' },
      { key: 'jueves', name: 'Jueves', emoji: '📋' },
      { key: 'viernes', name: 'Viernes', emoji: '📌' },
      { key: 'sabado', name: 'Sábado', emoji: '🎯' },
      { key: 'domingo', name: 'Domingo', emoji: '✨' }
    ],
    hours: Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))
  }),

  getters: {
    currentEmployee: (state) => {
      return state.employees.find(emp => emp.id === state.currentEmployeeId) || null
    },

    currentEmployeeWeeks(): Week[] {
      return this.currentEmployee?.weeks || []
    },

    currentWeek(): Week | null {
      if (!this.currentEmployee || !this.currentWeekId) return null
      return this.currentEmployee.weeks.find(week => week.id === this.currentWeekId) || null
    },

    weekTotals(): { totalHours: number; totalShifts: number; totalExtraHours: number; totalBasePay: number; totalPay: number } {
      if (!this.currentWeek) {
        return { totalHours: 0, totalShifts: 0, totalExtraHours: 0, totalBasePay: 0, totalPay: 0 }
      }

      const baseTotals = this.days.reduce((totals, day) => {
        const dayData = this.currentWeek!.schedule[day.key as keyof WeekSchedule]
        totals.totalHours += dayData.hoursWorked
        totals.totalShifts += dayData.completeShifts
        totals.totalExtraHours += dayData.extraHours
        totals.totalBasePay += dayData.dailyPay
        return totals
      }, { totalHours: 0, totalShifts: 0, totalExtraHours: 0, totalBasePay: 0 })

      const weeklyTips = this.currentWeek.weeklyTips || 0
      const totalPay = baseTotals.totalBasePay + weeklyTips

      return { ...baseTotals, totalPay }
    },

    totalWeeks: (state) => {
      return state.employees.reduce((total, emp) => total + emp.weeks.length, 0)
    }
  },

  actions: {
    // ===== UTILITY ACTIONS =====
    generateId(): string {
      return Date.now().toString(36) + Math.random().toString(36).substr(2)
    },

    formatCurrency(amount: number, currency: string | null = null): string {
      const curr = currency || this.currentEmployee?.settings?.currency || 'MXN'
      const symbol = this.currencySymbols[curr as keyof typeof this.currencySymbols] || '$'
      return `${symbol}${amount.toFixed(2)}`
    },

    formatWeekDisplay(dateStr: string): string {
      const date = new Date(dateStr)
      return date.toLocaleDateString('es-ES', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      })
    },

    getNextMonday(): Date {
      const today = new Date()
      const day = today.getDay()
      const diff = today.getDate() - day + (day === 0 ? -6 : 1)
      return new Date(today.setDate(diff))
    },

    createEmptyDaySchedule(): DaySchedule {
      return {
        entryHour: '',
        entryMinute: '',
        exitHour: '',
        exitMinute: '',
        hoursWorked: 0,
        completeShifts: 0,
        extraHours: 0,
        dailyPay: 0
      }
    },

    createEmptySchedule(): WeekSchedule {
      const schedule: Partial<WeekSchedule> = {}
      this.days.forEach(day => {
        schedule[day.key as keyof WeekSchedule] = this.createEmptyDaySchedule()
      })
      return schedule as WeekSchedule
    },

    // ===== EMPLOYEE MANAGEMENT =====
    // TODO: Convert to API call
    addNewEmployee(name: string): { success: boolean; error?: string } {
      const trimmedName = name.trim()

      if (!trimmedName) {
        return { success: false, error: 'El nombre del empleado es requerido' }
      }

      if (this.employees.some(emp => emp.name === trimmedName)) {
        return { success: false, error: 'Este empleado ya existe' }
      }

      const newEmployee: Employee = {
        id: this.generateId(),
        name: trimmedName,
        weeks: [],
        settings: {
          costPerTurn: 450,
          currency: 'MXN'
        }
      }

      this.employees.push(newEmployee)
      this.currentEmployeeId = newEmployee.id
      this.currentWeekId = ''

      this.saveSystemData()
      return { success: true }
    },

    // TODO: Convert to API call
    deleteCurrentEmployee(): { success: boolean; error?: string } {
      if (!this.currentEmployee || this.employees.length <= 1) {
        return { success: false, error: 'No puedes eliminar el último empleado del sistema' }
      }

      const index = this.employees.findIndex(emp => emp.id === this.currentEmployeeId)
      this.employees.splice(index, 1)

      this.currentEmployeeId = this.employees.length > 0 ? this.employees[0].id : ''
      this.currentWeekId = ''

      this.saveSystemData()
      return { success: true }
    },

    onEmployeeChange(): void {
      this.currentWeekId = ''
      this.saveSystemData()
    },

    // ===== WEEK MANAGEMENT =====
    // TODO: Convert to API call
    createNewWeek(): { success: boolean; error?: string } {
      if (!this.currentEmployee) {
        return { success: false, error: 'Primero selecciona o crea un empleado' }
      }

      const monday = this.getNextMonday()
      const weekKey = monday.toISOString().split('T')[0]

      if (this.currentEmployee.weeks.some(week => week.startDate === weekKey)) {
        return { success: false, error: 'Esta semana ya existe para este empleado' }
      }

      const newWeek: Week = {
        id: this.generateId(),
        startDate: weekKey,
        schedule: this.createEmptySchedule(),
        weeklyTips: 0,
        saved: false
      }

      this.currentEmployee.weeks.push(newWeek)
      this.currentWeekId = newWeek.id

      this.saveSystemData()
      return { success: true }
    },

    // TODO: Convert to API call
    saveCurrentWeek(): void {
      if (!this.currentWeek) return

      this.currentWeek.saved = true
      this.saveSystemData()
    },

    onWeekChange(): void {
      this.saveSystemData()
    },

    onSettingsChange(): void {
      if (!this.currentEmployee || !this.currentWeek) return

      // Recalcular todos los días con la nueva configuración
      this.days.forEach(day => this.calculateDay(day.key as keyof WeekSchedule))
      this.saveSystemData()
    },

    // ===== SCHEDULE CALCULATIONS =====
    calculateDay(dayKey: keyof WeekSchedule): void {
      if (!this.currentWeek) return

      const dayData = this.currentWeek.schedule[dayKey]
      const { entryHour, entryMinute, exitHour, exitMinute } = dayData

      if (!entryHour || !entryMinute || !exitHour || !exitMinute) {
        dayData.hoursWorked = 0
        dayData.completeShifts = 0
        dayData.extraHours = 0
        dayData.dailyPay = 0
        return
      }

      const entryTime = parseInt(entryHour) + parseInt(entryMinute) / 60
      let exitTime = parseInt(exitHour) + parseInt(exitMinute) / 60

      // Manejar turnos nocturnos
      if (exitTime <= entryTime) {
        exitTime += 24
      }

      const hoursWorked = exitTime - entryTime
      const completeShifts = Math.floor(hoursWorked / HOURS_PER_SHIFT)
      const extraHours = hoursWorked % HOURS_PER_SHIFT
      const costPerShift = this.currentEmployee?.settings?.costPerTurn || 450
      const dailyPay = (completeShifts * costPerShift) + (extraHours / HOURS_PER_SHIFT * costPerShift)

      dayData.hoursWorked = hoursWorked
      dayData.completeShifts = completeShifts
      dayData.extraHours = extraHours
      dayData.dailyPay = dailyPay

      this.saveSystemData()
    },

    // ===== REPORTS =====
    calculateWeekTotals(week: Week) {
      const baseTotals = this.days.reduce((totals, day) => {
        const dayData = week.schedule[day.key as keyof WeekSchedule]
        totals.totalHours += dayData.hoursWorked || 0
        totals.totalShifts += dayData.completeShifts || 0
        totals.totalExtraHours += dayData.extraHours || 0
        totals.totalBasePay += dayData.dailyPay || 0
        return totals
      }, { totalHours: 0, totalShifts: 0, totalExtraHours: 0, totalBasePay: 0 })

      const weeklyTips = week.weeklyTips || 0
      const totalPay = baseTotals.totalBasePay + weeklyTips

      return { ...baseTotals, totalPay }
    },

    calculateEmployeeStats(employee: Employee) {
      let totalWeeksCount = employee.weeks.length
      let totalHours = 0
      let totalShifts = 0
      let totalPay = 0

      employee.weeks.forEach(week => {
        this.days.forEach(day => {
          const dayData = week.schedule[day.key as keyof WeekSchedule]
          totalHours += dayData.hoursWorked || 0
          totalShifts += dayData.completeShifts || 0
          totalPay += dayData.dailyPay || 0
        })
        totalPay += week.weeklyTips || 0
      })

      return {
        totalWeeks: totalWeeksCount,
        totalHours,
        totalShifts,
        totalPay,
        avgHoursPerWeek: totalWeeksCount > 0 ? (totalHours / totalWeeksCount) : 0
      }
    },

    // ===== EXPORT / IMPORT =====
    // TODO: These will remain client-side but data will come from API
    exportSystemData(): void {
      const systemData: PayrollSystemData = {
        employees: this.employees,
        version: 'Vue 3.0',
        exportDate: new Date().toISOString(),
        currentEmployeeId: this.currentEmployeeId,
        currentWeekId: this.currentWeekId,
        activeTab: this.activeTab
      } as any

      const dataStr = JSON.stringify(systemData, null, 2)
      const blob = new Blob([dataStr], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `sistema_nomina_${new Date().toISOString().split('T')[0]}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    },

    async importSystemData(file: File): Promise<{ success: boolean; error?: string }> {
      return new Promise((resolve) => {
        const reader = new FileReader()

        reader.onload = (e) => {
          try {
            const content = e.target?.result as string
            const data = JSON.parse(content) as PayrollSystemData

            // Validar estructura básica
            if (!data.employees || !Array.isArray(data.employees)) {
              resolve({ success: false, error: 'Archivo inválido: falta estructura de empleados' })
              return
            }

            // Importar datos
            this.employees = data.employees

            // Si no hay currentEmployeeId o no es válido, seleccionar el primero
            if (!data.currentEmployeeId || !this.employees.find(e => e.id === data.currentEmployeeId)) {
              this.currentEmployeeId = this.employees.length > 0 ? this.employees[0].id : ''
            } else {
              this.currentEmployeeId = data.currentEmployeeId
            }

            this.currentWeekId = data.currentWeekId || ''
            this.activeTab = data.activeTab || 'schedules'

            this.saveSystemData()
            resolve({ success: true })
          } catch (error) {
            resolve({ success: false, error: 'Error al leer el archivo. Verifica que sea un archivo JSON válido.' })
          }
        }

        reader.onerror = () => {
          resolve({ success: false, error: 'Error al leer el archivo' })
        }

        reader.readAsText(file)
      })
    },

    exportAllEmployees(): void {
      let exportText = `=== REPORTE GENERAL DE NÓMINAS ===\n`
      exportText += `Fecha de exportación: ${new Date().toLocaleDateString()}\n`
      exportText += `Total de empleados: ${this.employees.length}\n\n`

      this.employees.forEach(employee => {
        const stats = this.calculateEmployeeStats(employee)
        const currency = this.currencySymbols[employee.settings.currency] || '$'

        exportText += `=== ${employee.name.toUpperCase()} ===\n`
        exportText += `Semanas registradas: ${stats.totalWeeks}\n`
        exportText += `Total de horas: ${stats.totalHours.toFixed(1)}\n`
        exportText += `Total de turnos: ${stats.totalShifts}\n`
        exportText += `Promedio horas/semana: ${stats.avgHoursPerWeek.toFixed(1)}\n`
        exportText += `PAGO TOTAL: ${currency}${stats.totalPay.toFixed(2)}\n\n`
      })

      const blob = new Blob([exportText], { type: 'text/plain' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `reporte_general_nominas_${new Date().toISOString().split('T')[0]}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    },

    exportEmployeeData(employee: Employee): void {
      const stats = this.calculateEmployeeStats(employee)
      const currency = this.currencySymbols[employee.settings.currency] || '$'

      let exportText = `=== REPORTE DE NÓMINA - ${employee.name.toUpperCase()} ===\n`
      exportText += `Costo por turno: ${currency}${employee.settings.costPerTurn}\n`
      exportText += `Moneda: ${employee.settings.currency}\n`
      exportText += `Fecha de exportación: ${new Date().toLocaleDateString()}\n\n`

      exportText += `=== RESUMEN GENERAL ===\n`
      exportText += `Semanas registradas: ${stats.totalWeeks}\n`
      exportText += `Total de horas: ${stats.totalHours.toFixed(1)}\n`
      exportText += `Total de turnos: ${stats.totalShifts}\n`
      exportText += `Promedio horas/semana: ${stats.avgHoursPerWeek.toFixed(1)}\n`
      exportText += `PAGO TOTAL: ${currency}${stats.totalPay.toFixed(2)}\n\n`

      exportText += `=== DETALLE POR SEMANAS ===\n`
      employee.weeks.sort((a, b) => new Date(b.startDate).getTime() - new Date(a.startDate).getTime()).forEach(week => {
        exportText += `\nSemana del ${this.formatWeekDisplay(week.startDate)}:\n`

        this.days.forEach(day => {
          const dayData = week.schedule[day.key as keyof WeekSchedule]
          if (dayData.hoursWorked > 0) {
            const entry = dayData.entryHour && dayData.entryMinute ?
              `${dayData.entryHour}:${dayData.entryMinute}` : '--:--'
            const exit = dayData.exitHour && dayData.exitMinute ?
              `${dayData.exitHour}:${dayData.exitMinute}` : '--:--'

            exportText += `  ${day.name}: ${entry} - ${exit} | ${dayData.hoursWorked.toFixed(1)}hrs | ${dayData.completeShifts} turnos | ${currency}${dayData.dailyPay.toFixed(2)}\n`
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
      a.download = `nomina_${employee.name.replace(/\s+/g, '_')}_${new Date().toISOString().split('T')[0]}.txt`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
    },

    // TODO: Convert to API call
    clearAllSystemData(): void {
      this.employees = []
      this.currentEmployeeId = ''
      this.currentWeekId = ''
      this.saveSystemData()
    },

    // ===== PERSISTENCE (will be replaced with API calls) =====
    // TODO: Replace with API fetch
    saveSystemData(): void {
      const systemData: PayrollSystemData = {
        employees: this.employees,
        currentEmployeeId: this.currentEmployeeId,
        currentWeekId: this.currentWeekId,
        activeTab: this.activeTab,
        version: 'Vue 3.0'
      }

      if (import.meta.client) {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(systemData))
      }
    },

    // TODO: Replace with API fetch
    loadSystemData(): void {
      if (!import.meta.client) return

      const saved = localStorage.getItem(STORAGE_KEY)

      if (saved) {
        try {
          const data = JSON.parse(saved) as PayrollSystemData
          this.employees = data.employees || []
          this.currentEmployeeId = data.currentEmployeeId || ''
          this.currentWeekId = data.currentWeekId || ''
          this.activeTab = data.activeTab || 'schedules'
        } catch (e) {
          console.error('Error loading data:', e)
          this.initializeDefaultData()
        }
      } else {
        this.initializeDefaultData()
      }
    },

    initializeDefaultData(): void {
      const defaultEmployee: Employee = {
        id: this.generateId(),
        name: 'Juan Pérez',
        weeks: [],
        settings: {
          costPerTurn: 450,
          currency: 'MXN'
        }
      }

      this.employees = [defaultEmployee]
      this.currentEmployeeId = defaultEmployee.id

      // Save the default data to localStorage
      this.saveSystemData()
    }
  }
})
