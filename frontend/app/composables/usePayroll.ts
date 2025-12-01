import { createSharedComposable } from '@vueuse/core'

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

const _usePayroll = () => {
  // Estado reactivo
  const employees = ref<Employee[]>([])
  const currentEmployeeId = ref('')
  const currentWeekId = ref('')
  const activeTab = ref('schedules')

  // Constantes
  const currencySymbols = { MXN: '$', USD: '$', EUR: '€' }

  const days = [
    { key: 'lunes', name: 'Lunes', emoji: '📅' },
    { key: 'martes', name: 'Martes', emoji: '📊' },
    { key: 'miercoles', name: 'Miércoles', emoji: '📈' },
    { key: 'jueves', name: 'Jueves', emoji: '📋' },
    { key: 'viernes', name: 'Viernes', emoji: '📌' },
    { key: 'sabado', name: 'Sábado', emoji: '🎯' },
    { key: 'domingo', name: 'Domingo', emoji: '✨' }
  ]

  const hours = Array.from({ length: 24 }, (_, i) => String(i).padStart(2, '0'))

  // Computed properties
  const currentEmployee = computed(() => {
    return employees.value.find(emp => emp.id === currentEmployeeId.value) || null
  })

  const currentEmployeeWeeks = computed(() => {
    return currentEmployee.value?.weeks || []
  })

  const currentWeek = computed(() => {
    if (!currentEmployee.value || !currentWeekId.value) return null
    return currentEmployee.value.weeks.find(week => week.id === currentWeekId.value) || null
  })

  const weekTotals = computed(() => {
    if (!currentWeek.value) {
      return { totalHours: 0, totalShifts: 0, totalExtraHours: 0, totalBasePay: 0, totalPay: 0 }
    }

    const baseTotals = days.reduce((totals, day) => {
      const dayData = currentWeek.value!.schedule[day.key as keyof WeekSchedule]
      totals.totalHours += dayData.hoursWorked
      totals.totalShifts += dayData.completeShifts
      totals.totalExtraHours += dayData.extraHours
      totals.totalBasePay += dayData.dailyPay
      return totals
    }, { totalHours: 0, totalShifts: 0, totalExtraHours: 0, totalBasePay: 0 })

    const weeklyTips = currentWeek.value.weeklyTips || 0
    const totalPay = baseTotals.totalBasePay + weeklyTips

    return { ...baseTotals, totalPay }
  })

  const totalWeeks = computed(() => {
    return employees.value.reduce((total, emp) => total + emp.weeks.length, 0)
  })

  // Funciones auxiliares
  const generateId = () => Date.now().toString(36) + Math.random().toString(36).substr(2)

  const formatCurrency = (amount: number, currency: string | null = null) => {
    const curr = currency || currentEmployee.value?.settings?.currency || 'MXN'
    const symbol = currencySymbols[curr as keyof typeof currencySymbols] || '$'
    return `${symbol}${amount.toFixed(2)}`
  }

  const formatWeekDisplay = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString('es-ES', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    })
  }

  const getNextMonday = () => {
    const today = new Date()
    const day = today.getDay()
    const diff = today.getDate() - day + (day === 0 ? -6 : 1)
    return new Date(today.setDate(diff))
  }

  const createEmptyDaySchedule = (): DaySchedule => ({
    entryHour: '',
    entryMinute: '',
    exitHour: '',
    exitMinute: '',
    hoursWorked: 0,
    completeShifts: 0,
    extraHours: 0,
    dailyPay: 0
  })

  const createEmptySchedule = (): WeekSchedule => {
    const schedule: Partial<WeekSchedule> = {}
    days.forEach(day => {
      schedule[day.key as keyof WeekSchedule] = createEmptyDaySchedule()
    })
    return schedule as WeekSchedule
  }

  // Gestión de empleados
  const addNewEmployee = (name: string): { success: boolean; error?: string } => {
    const trimmedName = name.trim()

    if (!trimmedName) {
      return { success: false, error: 'El nombre del empleado es requerido' }
    }

    if (employees.value.some(emp => emp.name === trimmedName)) {
      return { success: false, error: 'Este empleado ya existe' }
    }

    const newEmployee: Employee = {
      id: generateId(),
      name: trimmedName,
      weeks: [],
      settings: {
        costPerTurn: 450,
        currency: 'MXN'
      }
    }

    employees.value.push(newEmployee)
    currentEmployeeId.value = newEmployee.id
    currentWeekId.value = ''

    saveSystemData()
    return { success: true }
  }

  const deleteCurrentEmployee = (): { success: boolean; error?: string } => {
    if (!currentEmployee.value || employees.value.length <= 1) {
      return { success: false, error: 'No puedes eliminar el último empleado del sistema' }
    }

    const index = employees.value.findIndex(emp => emp.id === currentEmployeeId.value)
    employees.value.splice(index, 1)

    currentEmployeeId.value = employees.value.length > 0 ? employees.value[0].id : ''
    currentWeekId.value = ''

    saveSystemData()
    return { success: true }
  }

  const onEmployeeChange = () => {
    currentWeekId.value = ''
    saveSystemData()
  }

  // Gestión de semanas
  const createNewWeek = (): { success: boolean; error?: string } => {
    if (!currentEmployee.value) {
      return { success: false, error: 'Primero selecciona o crea un empleado' }
    }

    const monday = getNextMonday()
    const weekKey = monday.toISOString().split('T')[0]

    if (currentEmployee.value.weeks.some(week => week.startDate === weekKey)) {
      return { success: false, error: 'Esta semana ya existe para este empleado' }
    }

    const newWeek: Week = {
      id: generateId(),
      startDate: weekKey,
      schedule: createEmptySchedule(),
      weeklyTips: 0,
      saved: false
    }

    currentEmployee.value.weeks.push(newWeek)
    currentWeekId.value = newWeek.id

    saveSystemData()
    return { success: true }
  }

  const saveCurrentWeek = () => {
    if (!currentWeek.value) return

    currentWeek.value.saved = true
    saveSystemData()
  }

  const onWeekChange = () => {
    saveSystemData()
  }

  const onSettingsChange = () => {
    if (!currentEmployee.value || !currentWeek.value) return

    // Recalcular todos los días con la nueva configuración
    days.forEach(day => calculateDay(day.key as keyof WeekSchedule))
    saveSystemData()
  }

  // Cálculos de horarios
  const calculateDay = (dayKey: keyof WeekSchedule) => {
    if (!currentWeek.value) return

    const dayData = currentWeek.value.schedule[dayKey]
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
    const costPerShift = currentEmployee.value?.settings?.costPerTurn || 450
    const dailyPay = (completeShifts * costPerShift) + (extraHours / HOURS_PER_SHIFT * costPerShift)

    dayData.hoursWorked = hoursWorked
    dayData.completeShifts = completeShifts
    dayData.extraHours = extraHours
    dayData.dailyPay = dailyPay

    saveSystemData()
  }

  // Reportes
  const calculateEmployeeStats = (employee: Employee) => {
    let totalWeeksCount = employee.weeks.length
    let totalHours = 0
    let totalShifts = 0
    let totalPay = 0

    employee.weeks.forEach(week => {
      days.forEach(day => {
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
  }

  // Exportación e Importación
  const exportSystemData = () => {
    const systemData: PayrollSystemData = {
      employees: employees.value,
      version: 'Vue 3.0',
      exportDate: new Date().toISOString(),
      currentEmployeeId: currentEmployeeId.value,
      currentWeekId: currentWeekId.value,
      activeTab: activeTab.value
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
  }

  const importSystemData = (file: File): Promise<{ success: boolean; error?: string }> => {
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
          employees.value = data.employees
          currentEmployeeId.value = data.currentEmployeeId || ''
          currentWeekId.value = data.currentWeekId || ''
          activeTab.value = data.activeTab || 'schedules'

          saveSystemData()
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
  }

  const exportAllEmployees = () => {
    let exportText = `=== REPORTE GENERAL DE NÓMINAS ===\n`
    exportText += `Fecha de exportación: ${new Date().toLocaleDateString()}\n`
    exportText += `Total de empleados: ${employees.value.length}\n\n`

    employees.value.forEach(employee => {
      const stats = calculateEmployeeStats(employee)
      const currency = currencySymbols[employee.settings.currency] || '$'

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
  }

  const exportEmployeeData = (employee: Employee) => {
    const stats = calculateEmployeeStats(employee)
    const currency = currencySymbols[employee.settings.currency] || '$'

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
      exportText += `\nSemana del ${formatWeekDisplay(week.startDate)}:\n`

      days.forEach(day => {
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
  }

  const clearAllSystemData = () => {
    employees.value = []
    currentEmployeeId.value = ''
    currentWeekId.value = ''
    saveSystemData()
  }

  // Persistencia
  const saveSystemData = () => {
    const systemData: PayrollSystemData = {
      employees: employees.value,
      currentEmployeeId: currentEmployeeId.value,
      currentWeekId: currentWeekId.value,
      activeTab: activeTab.value,
      version: 'Vue 3.0'
    }

    if (import.meta.client) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(systemData))
    }
  }

  const loadSystemData = () => {
    if (!import.meta.client) return

    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      try {
        const data = JSON.parse(saved) as PayrollSystemData
        employees.value = data.employees || []
        currentEmployeeId.value = data.currentEmployeeId || ''
        currentWeekId.value = data.currentWeekId || ''
        activeTab.value = data.activeTab || 'schedules'
      } catch (e) {
        console.error('Error loading data:', e)
        initializeDefaultData()
      }
    } else {
      initializeDefaultData()
    }
  }

  const initializeDefaultData = () => {
    const defaultEmployee: Employee = {
      id: generateId(),
      name: 'Juan Pérez',
      weeks: [],
      settings: {
        costPerTurn: 450,
        currency: 'MXN'
      }
    }

    employees.value = [defaultEmployee]
    currentEmployeeId.value = defaultEmployee.id
  }

  // Auto-save
  watch([employees, currentEmployeeId, currentWeekId], saveSystemData, { deep: true })

  return {
    // Estado
    employees,
    currentEmployeeId,
    currentWeekId,
    activeTab,

    // Constantes
    days,
    hours,
    currencySymbols,

    // Computed
    currentEmployee,
    currentEmployeeWeeks,
    currentWeek,
    weekTotals,
    totalWeeks,

    // Funciones
    formatCurrency,
    formatWeekDisplay,
    calculateDay,
    calculateEmployeeStats,
    addNewEmployee,
    deleteCurrentEmployee,
    onEmployeeChange,
    createNewWeek,
    saveCurrentWeek,
    onWeekChange,
    onSettingsChange,
    exportSystemData,
    importSystemData,
    exportAllEmployees,
    exportEmployeeData,
    clearAllSystemData,
    loadSystemData,
    saveSystemData
  }
}

export const usePayroll = createSharedComposable(_usePayroll)
