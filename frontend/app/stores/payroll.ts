import { defineStore } from 'pinia'
import type { PayrollEmployee, PayrollWeek, DaySchedule, WeekSchedule, EmployeeSettings } from '~/types/payroll'
import { calculateWeekTotals } from '~/utils/payrollCalculations'

/**
 * Store de Pinia para el módulo de Nóminas (Setup Syntax)
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
export const usePayrollStore = defineStore('payroll', () => {
  // ===== STATE =====
  const employees = ref<PayrollEmployee[]>([])
  const currentEmployeeId = ref('')
  const currentWeekId = ref('')
  const activeTab = ref('schedules')
  const loading = ref(false)
  const error = ref<string | undefined>(undefined)

  // ===== GETTERS (Computed) =====

  /**
   * Empleado actualmente seleccionado
   */
  const currentEmployee = computed<PayrollEmployee | null>(() => {
    return employees.value.find(emp => emp.id === currentEmployeeId.value) || null
  })

  /**
   * Semanas del empleado actual
   */
  const currentEmployeeWeeks = computed<PayrollWeek[]>(() => {
    return currentEmployee.value?.weeks || []
  })

  /**
   * Semana actualmente seleccionada
   */
  const currentWeek = computed<PayrollWeek | null>(() => {
    if (!currentEmployee.value || !currentWeekId.value) return null
    return currentEmployee.value.weeks.find(week => week.id === currentWeekId.value) || null
  })

  /**
   * Totales de la semana actual
   * Usa la función de cálculo de utils/payrollCalculations.ts
   */
  const weekTotals = computed(() => {
    if (!currentWeek.value) {
      return {
        totalHours: 0,
        regularHours: 0,
        overtimeHours: 0,
        extraHours: 0,
        totalBasePay: 0,
        totalPay: 0
      }
    }

    return calculateWeekTotals(currentWeek.value)
  })

  /**
   * Total de semanas de todos los empleados
   */
  const totalWeeks = computed<number>(() => {
    return employees.value.reduce((total, emp) => total + emp.weeks.length, 0)
  })

  // ===== ACTIONS (Functions) =====

  // --- CRUD: EMPLEADOS ---

  /**
   * Obtiene todos los empleados desde el backend
   */
  async function fetchEmployees() {
    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      employees.value = await api.fetchEmployees()

      // Seleccionar primer empleado si no hay ninguno seleccionado
      if (!currentEmployeeId.value || !employees.value.find(e => e.id === currentEmployeeId.value)) {
        currentEmployeeId.value = employees.value.length > 0 ? employees.value[0]?.id || '' : ''
      }
    } catch (err: any) {
      error.value = err?.message || 'Error al cargar empleados'
      console.error('Error fetching employees:', err)
    } finally {
      loading.value = false
    }
  }

  /**
   * Crea un nuevo empleado
   */
  async function createEmployee(
    name: string,
    baseHourlyRate: number,
    currency: string = 'MXN'
  ): Promise<{ success: boolean; error?: string }> {
    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      const newEmployee = await api.createEmployee({
        name: name.trim(),
        base_hourly_rate: baseHourlyRate,
        currency
      })

      employees.value.push(newEmployee)
      currentEmployeeId.value = newEmployee.id
      currentWeekId.value = ''

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al crear empleado'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Actualiza la configuración de un empleado
   */
  async function updateEmployeeSettings(
    settings: Partial<EmployeeSettings>
  ): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value) {
      return { success: false, error: 'No hay empleado seleccionado' }
    }

    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      const updatedEmployee = await api.updateEmployee(currentEmployeeId.value, { settings } as { settings: EmployeeSettings })

      // Actualizar en el estado local
      const index = employees.value.findIndex(e => e.id === currentEmployeeId.value)
      if (index !== -1) {
        employees.value[index] = updatedEmployee
      }

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al actualizar configuración'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Elimina el empleado actual
   */
  async function deleteCurrentEmployee(): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value) {
      return { success: false, error: 'No hay empleado seleccionado' }
    }

    if (employees.value.length <= 1) {
      return { success: false, error: 'No puedes eliminar el último empleado' }
    }

    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      await api.deleteEmployee(currentEmployeeId.value)

      // Remover del estado local
      const index = employees.value.findIndex(e => e.id === currentEmployeeId.value)
      if (index !== -1) {
        employees.value.splice(index, 1)
      }

      // Seleccionar primer empleado
      currentEmployeeId.value = employees.value.length > 0 ? employees.value[0]?.id || '' : ''
      currentWeekId.value = ''

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al eliminar empleado'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Maneja el cambio de empleado seleccionado
   */
  function onEmployeeChange(): void {
    currentWeekId.value = ''
  }

  // --- CRUD: SEMANAS ---

  /**
   * Crea una nueva semana laboral
   */
  async function createWeek(
    startDate: string,
    weeklyTips: number = 0
  ): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value) {
      return { success: false, error: 'No hay empleado seleccionado' }
    }

    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      const newWeek = await api.createWeek(currentEmployeeId.value, {
        start_date: startDate,
        weekly_tips: weeklyTips
      })

      // Agregar al estado local
      const employee = employees.value.find(e => e.id === currentEmployeeId.value)
      if (employee) {
        employee.weeks.push(newWeek)
        currentWeekId.value = newWeek.id
      }

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al crear semana'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Actualiza el horario de un día específico
   */
  async function updateDaySchedule(
    dayKey: keyof WeekSchedule,
    schedule: Partial<DaySchedule>
  ): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value || !currentWeekId.value) {
      return { success: false, error: 'No hay empleado o semana seleccionada' }
    }

    loading.value = true
    error.value = undefined

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
        currentEmployeeId.value,
        currentWeekId.value,
        { [dayKey]: rawSchedule }
      )

      // Actualizar estado local con valores calculados del backend
      const employee = employees.value.find(e => e.id === currentEmployeeId.value)
      if (employee) {
        const weekIndex = employee.weeks.findIndex(w => w.id === currentWeekId.value)
        if (weekIndex !== -1) {
          employee.weeks[weekIndex] = updatedWeek
        }
      }

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al actualizar horario'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Actualiza las propinas semanales
   */
  async function updateWeeklyTips(tips: number): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value || !currentWeekId.value) {
      return { success: false, error: 'No hay empleado o semana seleccionada' }
    }

    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      const updatedWeek = await api.updateWeek(
        currentEmployeeId.value,
        currentWeekId.value,
        { weekly_tips: tips }
      )

      // Actualizar estado local
      const employee = employees.value.find(e => e.id === currentEmployeeId.value)
      if (employee) {
        const weekIndex = employee.weeks.findIndex(w => w.id === currentWeekId.value)
        if (weekIndex !== -1) {
          employee.weeks[weekIndex] = updatedWeek
        }
      }

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al actualizar propinas'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  /**
   * Elimina la semana actual
   */
  async function deleteCurrentWeek(): Promise<{ success: boolean; error?: string }> {
    if (!currentEmployeeId.value || !currentWeekId.value) {
      return { success: false, error: 'No hay empleado o semana seleccionada' }
    }

    loading.value = true
    error.value = undefined

    try {
      const api = usePayrollApi()
      await api.deleteWeek(currentEmployeeId.value, currentWeekId.value)

      // Remover del estado local
      const employee = employees.value.find(e => e.id === currentEmployeeId.value)
      if (employee) {
        const weekIndex = employee.weeks.findIndex(w => w.id === currentWeekId.value)
        if (weekIndex !== -1) {
          employee.weeks.splice(weekIndex, 1)
        }
      }

      currentWeekId.value = ''

      return { success: true }
    } catch (err: any) {
      error.value = err?.message || 'Error al eliminar semana'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }

  // ===== RETURN PUBLIC API =====
  return {
    // State
    employees,
    currentEmployeeId,
    currentWeekId,
    activeTab,
    loading,
    error,
    // Getters
    currentEmployee,
    currentEmployeeWeeks,
    currentWeek,
    weekTotals,
    totalWeeks,
    // Actions
    fetchEmployees,
    createEmployee,
    updateEmployeeSettings,
    deleteCurrentEmployee,
    onEmployeeChange,
    createWeek,
    updateDaySchedule,
    updateWeeklyTips,
    deleteCurrentWeek
  }
})
