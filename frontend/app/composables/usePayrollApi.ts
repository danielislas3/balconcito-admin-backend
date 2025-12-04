import type { PayrollEmployee, PayrollWeek } from '~/types/payroll'

export const usePayrollApi = () => {
  const config = useRuntimeConfig()
  const { getToken } = useAuth()

  const fetchEmployees = async (): Promise<PayrollEmployee[]> => {
    const token = await getToken()
    const response = await $fetch<{ employees: PayrollEmployee[] }>(
      `${config.public.apiBase}/payroll_employees`,
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    )
    return response.employees
  }

  const fetchEmployee = async (employeeId: string): Promise<PayrollEmployee> => {
    const token = await getToken()
    const response = await $fetch<{ employee: PayrollEmployee }>(
      `${config.public.apiBase}/payroll_employees/${employeeId}`,
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    )
    return response.employee
  }

  const createEmployee = async (data: {
    name: string
    base_hourly_rate: number
    currency: string
  }): Promise<PayrollEmployee> => {
    const token = await getToken()
    const response = await $fetch<{ employee: PayrollEmployee }>(
      `${config.public.apiBase}/payroll_employees`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: { payroll_employee: data }
      }
    )
    return response.employee
  }

  const updateEmployee = async (
    employeeId: string,
    data: Partial<PayrollEmployee>
  ): Promise<PayrollEmployee> => {
    const token = await getToken()
    const response = await $fetch<{ employee: PayrollEmployee }>(
      `${config.public.apiBase}/payroll_employees/${employeeId}`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: { payroll_employee: data }
      }
    )
    return response.employee
  }

  const deleteEmployee = async (employeeId: string): Promise<void> => {
    const token = await getToken()
    await $fetch(`${config.public.apiBase}/payroll_employees/${employeeId}`, {
      method: 'DELETE',
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
  }

  const createWeek = async (
    employeeId: string,
    data: { start_date: string; weekly_tips?: number }
  ): Promise<PayrollWeek> => {
    const token = await getToken()
    const response = await $fetch<{ week: PayrollWeek }>(
      `${config.public.apiBase}/payroll_employees/${employeeId}/weeks`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: { payroll_week: data }
      }
    )
    return response.week
  }

  const updateWeekSchedule = async (
    employeeId: string,
    weekId: string,
    schedule: Record<string, any>
  ): Promise<PayrollWeek> => {
    const token = await getToken()
    const response = await $fetch<{ week: PayrollWeek }>(
      `${config.public.apiBase}/payroll_employees/${employeeId}/weeks/${weekId}/update_schedule`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: { schedule }
      }
    )
    return response.week
  }

  const updateWeek = async (
    employeeId: string,
    weekId: string,
    data: { weekly_tips?: number }
  ): Promise<PayrollWeek> => {
    const token = await getToken()
    const response = await $fetch<{ week: PayrollWeek }>(
      `${config.public.apiBase}/payroll_employees/${employeeId}/weeks/${weekId}`,
      {
        method: 'PATCH',
        headers: {
          Authorization: `Bearer ${token}`
        },
        body: { payroll_week: data }
      }
    )
    return response.week
  }

  const deleteWeek = async (employeeId: string, weekId: string): Promise<void> => {
    const token = await getToken()
    await $fetch(
      `${config.public.apiBase}/payroll_employees/${employeeId}/weeks/${weekId}`,
      {
        method: 'DELETE',
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    )
  }

  return {
    fetchEmployees,
    fetchEmployee,
    createEmployee,
    updateEmployee,
    deleteEmployee,
    createWeek,
    updateWeekSchedule,
    updateWeek,
    deleteWeek
  }
}
