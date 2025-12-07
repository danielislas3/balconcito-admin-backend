import { defineStore } from 'pinia'
import type { PayrollEmployee, PayrollWeek, DaySchedule, WeekSchedule, EmployeeSettings } from '~/types/payroll'
import { calculateWeekTotals } from '~/utils/payrollCalculations'

/**
 * Store de Pinia para el módulo de Nóminas
 *
 * Maneja el estado y las acciones relacionadas con empleados de nómina,
 * semanas laborales y horarios. Utiliza el patrón Repository a través
 * de usePayrollApi para todas las operaciones con el backend.
 *
 * Las funciones de cálculo, formateo y exportación están en archivos separados:
 * - utils/payrollCalculations.ts
 * - utils/payrollFormatters.ts
 * - composables/usePayrollExport.ts
 */
export const usePayrollStore = defineStore('payroll', {
  state: () => ({
    // Datos principales
    employees: [] as PayrollEmployee[],

    // UI State
    currentEmployeeId: '',
    currentWeekId: '',
    activeTab: 'schedules' as string,

    // Loading & Error states
    loading: false,
    error: null as string | null
  }),

  getters: {
    /**
     * Empleado actualmente seleccionado
     */
    currentEmployee: (state): PayrollEmployee | null => {
      return state.employees.find(emp => emp.id === state.currentEmployeeId) || null
    },

    /**
     * Semanas del empleado actual
     */
    currentEmployeeWeeks(): PayrollWeek[] {
      return this.currentEmployee?.weeks || []
    },

    /**
     * Semana actualmente seleccionada
     */
    currentWeek(): PayrollWeek | null => {
      if (!this.currentEmployee || !this.currentWeekId) return null
      return this.currentEmployee.weeks.find(week => week.id === this.currentWeekId) || null
    },

    /**
     * Totales de la semana actual
     * Usa la función de cálculo de utils/payrollCalculations.ts
     */
    weekTotals() {
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

      return calculateWeekTotals(this.currentWeek)
    },

    /**
     * Total de semanas de todos los empleados
     */
    totalWeeks: (state): number => {
      return state.employees.reduce((total, emp) => total + emp.weeks.length, 0)
    }
  },

  actions: {
    // ===== CRUD: EMPLEADOS =====

    /**
     * Obtiene todos los empleados desde el backend
     */
    async fetchEmployees() {
      this.loading = true
      this.error = null

      try {
        const api = usePayrollApi()
        this.employees = await api.fetchEmployees()

        // Seleccionar primer empleado si no hay ninguno seleccionado
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

    /**
     * Crea un nuevo empleado
     */
    async createEmployee(
      name: string,
      baseHourlyRate: number,
      currency: string = 'MXN'
    ): Promise<{ success: boolean; error?: string }> {
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

    /**
     * Actualiza la configuración de un empleado
     */
    async updateEmployeeSettings(
      settings: Partial<EmployeeSettings>
    ): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId) {
        return { success: false, error: 'No hay empleado seleccionado' }
      }

      this.loading = true
      this.error = null

      try {
        const api = usePayrollApi()
        const updatedEmployee = await api.updateEmployee(this.currentEmployeeId, { settings })

        // Actualizar en el estado local
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

    /**
     * Elimina el empleado actual
     */
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

        // Remover del estado local
        const index = this.employees.findIndex(e => e.id === this.currentEmployeeId)
        if (index !== -1) {
          this.employees.splice(index, 1)
        }

        // Seleccionar primer empleado
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

    /**
     * Maneja el cambio de empleado seleccionado
     */
    onEmployeeChange(): void {
      this.currentWeekId = ''
    },

    // ===== CRUD: SEMANAS =====

    /**
     * Crea una nueva semana laboral
     */
    async createWeek(
      startDate: string,
      weeklyTips: number = 0
    ): Promise<{ success: boolean; error?: string }> {
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

        // Agregar al estado local
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

    /**
     * Actualiza el horario de un día específico
     */
    async updateDaySchedule(
      dayKey: keyof WeekSchedule,
      schedule: Partial<DaySchedule>
    ): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId || !this.currentWeekId) {
        return { success: false, error: 'No hay empleado o semana seleccionada' }
      }

      this.loading = true
      this.error = null

      try {
        const api = usePayrollApi()

        // Enviar solo datos raw al backend (entry/exit times, isWorking)
        // El backend calculará todo lo demás
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

        // Actualizar estado local con valores calculados del backend
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

    /**
     * Actualiza las propinas semanales
     */
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

        // Actualizar estado local
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

    /**
     * Elimina la semana actual
     */
    async deleteCurrentWeek(): Promise<{ success: boolean; error?: string }> {
      if (!this.currentEmployeeId || !this.currentWeekId) {
        return { success: false, error: 'No hay empleado o semana seleccionada' }
      }

      this.loading = true
      this.error = null

      try {
        const api = usePayrollApi()
        await api.deleteWeek(this.currentEmployeeId, this.currentWeekId)

        // Remover del estado local
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
    }
  }
})
