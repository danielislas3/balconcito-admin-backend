import type { PayrollEmployee, PayrollWeek } from '~/types/payroll'

/**
 * API client para el módulo de Nóminas (Payroll)
 *
 * Este composable proporciona una interfaz limpia y tipada para todas las operaciones
 * relacionadas con empleados de nómina y sus semanas laborales.
 *
 * Sigue el patrón de Repository, centralizando todos los endpoints del módulo
 * y utilizando el composable base `useApi` para las peticiones HTTP.
 *
 * @example
 * ```typescript
 * const payrollApi = usePayrollApi()
 *
 * // Obtener todos los empleados
 * const employees = await payrollApi.fetchEmployees()
 *
 * // Crear un nuevo empleado
 * const newEmployee = await payrollApi.createEmployee({
 *   name: 'Juan Pérez',
 *   base_hourly_rate: 450,
 *   currency: 'MXN'
 * })
 *
 * // Crear una nueva semana
 * const week = await payrollApi.createWeek(employeeId, {
 *   start_date: '2025-01-13',
 *   weekly_tips: 500
 * })
 * ```
 */
export const usePayrollApi = () => {
  const api = useApi()

  // ===== ENDPOINTS DE EMPLEADOS =====

  /**
   * Obtiene todos los empleados de nómina
   * @returns Lista de empleados con sus semanas y configuraciones
   */
  const fetchEmployees = async (): Promise<PayrollEmployee[]> => {
    const response = await api.get<{ employees: PayrollEmployee[] }>(
      '/payroll_employees',
      { context: 'fetchEmployees' }
    )
    return response.employees
  }

  /**
   * Obtiene un empleado específico por ID
   * @param employeeId - ID del empleado
   * @returns Empleado con todas sus semanas
   */
  const fetchEmployee = async (employeeId: string): Promise<PayrollEmployee> => {
    const response = await api.get<{ employee: PayrollEmployee }>(
      `/payroll_employees/${employeeId}`,
      { context: 'fetchEmployee' }
    )
    return response.employee
  }

  /**
   * Crea un nuevo empleado de nómina
   * @param data - Datos del empleado (nombre, tarifa horaria, moneda)
   * @returns Empleado creado
   */
  const createEmployee = async (data: {
    name: string
    base_hourly_rate: number
    currency: string
  }): Promise<PayrollEmployee> => {
    const response = await api.post<{ employee: PayrollEmployee }>(
      '/payroll_employees',
      { payroll_employee: data },
      { context: 'createEmployee' }
    )
    return response.employee
  }

  /**
   * Actualiza un empleado existente
   * @param employeeId - ID del empleado
   * @param data - Datos a actualizar (puede ser parcial)
   * @returns Empleado actualizado
   */
  const updateEmployee = async (
    employeeId: string,
    data: Partial<PayrollEmployee>
  ): Promise<PayrollEmployee> => {
    const response = await api.patch<{ employee: PayrollEmployee }>(
      `/payroll_employees/${employeeId}`,
      { payroll_employee: data },
      { context: 'updateEmployee' }
    )
    return response.employee
  }

  /**
   * Elimina un empleado
   * @param employeeId - ID del empleado a eliminar
   */
  const deleteEmployee = async (employeeId: string): Promise<void> => {
    await api.delete(
      `/payroll_employees/${employeeId}`,
      { context: 'deleteEmployee' }
    )
  }

  // ===== ENDPOINTS DE SEMANAS =====

  /**
   * Crea una nueva semana laboral para un empleado
   * @param employeeId - ID del empleado
   * @param data - Datos de la semana (fecha de inicio, propinas opcionales)
   * @returns Semana creada con horarios inicializados
   */
  const createWeek = async (
    employeeId: string,
    data: { start_date: string; weekly_tips?: number }
  ): Promise<PayrollWeek> => {
    const response = await api.post<{ week: PayrollWeek }>(
      `/payroll_employees/${employeeId}/weeks`,
      { payroll_week: data },
      { context: 'createWeek' }
    )
    return response.week
  }

  /**
   * Actualiza el horario de una semana
   * @param employeeId - ID del empleado
   * @param weekId - ID de la semana
   * @param schedule - Horarios por día (lunes, martes, etc.)
   * @returns Semana actualizada con cálculos de pago
   */
  const updateWeekSchedule = async (
    employeeId: string,
    weekId: string,
    schedule: Record<string, any>
  ): Promise<PayrollWeek> => {
    const response = await api.patch<{ week: PayrollWeek }>(
      `/payroll_employees/${employeeId}/weeks/${weekId}/update_schedule`,
      { schedule },
      { context: 'updateWeekSchedule' }
    )
    return response.week
  }

  /**
   * Actualiza datos generales de una semana (propinas, etc.)
   * @param employeeId - ID del empleado
   * @param weekId - ID de la semana
   * @param data - Datos a actualizar
   * @returns Semana actualizada
   */
  const updateWeek = async (
    employeeId: string,
    weekId: string,
    data: { weekly_tips?: number }
  ): Promise<PayrollWeek> => {
    const response = await api.patch<{ week: PayrollWeek }>(
      `/payroll_employees/${employeeId}/weeks/${weekId}`,
      { payroll_week: data },
      { context: 'updateWeek' }
    )
    return response.week
  }

  /**
   * Elimina una semana laboral
   * @param employeeId - ID del empleado
   * @param weekId - ID de la semana a eliminar
   */
  const deleteWeek = async (employeeId: string, weekId: string): Promise<void> => {
    await api.delete(
      `/payroll_employees/${employeeId}/weeks/${weekId}`,
      { context: 'deleteWeek' }
    )
  }

  // Retornar todas las funciones disponibles
  return {
    // Empleados
    fetchEmployees,
    fetchEmployee,
    createEmployee,
    updateEmployee,
    deleteEmployee,

    // Semanas
    createWeek,
    updateWeekSchedule,
    updateWeek,
    deleteWeek
  }
}
