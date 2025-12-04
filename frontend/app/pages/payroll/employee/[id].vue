<script setup lang="ts">
import type { Employee, Week, WeekSchedule } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'

definePageMeta({
  layout: 'default',
  requiresAuth: false
})

const route = useRoute()
const router = useRouter()
const payrollStore = usePayrollStore()
const toast = useToast()

// Get employee from route params
const employeeId = route.params.id as string
const employee = computed(() =>
  payrollStore.employees.find(emp => emp.id === employeeId) || null
)

// Redirect if employee not found
watch(employee, (emp) => {
  if (!emp && import.meta.client) {
    toast.add({
      title: 'Error',
      description: 'Empleado no encontrado',
      color: 'error'
    })
    router.push('/payroll')
  }
}, { immediate: true })

// Sort weeks by date (newest first)
const sortedWeeks = computed(() => {
  if (!employee.value) return []
  return [...employee.value.weeks].sort((a, b) =>
    new Date(b.startDate).getTime() - new Date(a.startDate).getTime()
  )
})

// Calculate comprehensive employee stats for HR
const employeeStats = computed(() => {
  if (!employee.value) return null

  const stats = payrollStore.calculateEmployeeStats(employee.value)
  const weeks = employee.value.weeks

  // Calculate additional metrics for HR
  let totalDaysWorked = 0
  let totalDaysPossible = weeks.length * 7
  let totalOvertimeHours = 0
  let weeksWithOvertime = 0
  let perfectWeeks = 0

  weeks.forEach(week => {
    let shiftsThisWeek = 0
    let hasOvertime = false

    payrollStore.days.forEach(day => {
      const dayData = week.schedule[day.key as keyof WeekSchedule]
      if (dayData.hoursWorked > 0) {
        totalDaysWorked++
      }
      shiftsThisWeek += dayData.completeShifts
      if (dayData.extraHours > 0) {
        totalOvertimeHours += dayData.extraHours
        hasOvertime = true
      }
    })

    if (hasOvertime) weeksWithOvertime++
    if (shiftsThisWeek >= 7) perfectWeeks++
  })

  const consistencyScore = totalDaysPossible > 0 ? (totalDaysWorked / totalDaysPossible) * 100 : 0
  const avgPayPerDay = totalDaysWorked > 0 ? stats.totalPay / totalDaysWorked : 0
  const overtimeFrequency = weeks.length > 0 ? (weeksWithOvertime / weeks.length) * 100 : 0

  return {
    ...stats,
    totalDaysWorked,
    totalDaysPossible,
    totalOvertimeHours,
    weeksWithOvertime,
    perfectWeeks,
    consistencyScore: consistencyScore,
    avgPayPerDay,
    overtimeFrequency,
    attendanceRate: consistencyScore
  }
})

const exportEmployeeData = () => {
  if (employee.value) {
    payrollStore.exportEmployeeData(employee.value)
  }
}
</script>

<template>
  <div class="min-h-screen w-full bg-gradient-to-br from-emerald-50 via-white to-teal-50 dark:from-gray-900 dark:via-gray-800 dark:to-emerald-950 overflow-y-auto">
    <div v-if="employee && employeeStats" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">

      <!-- Header with back button -->
      <div class="flex items-center gap-4 flex-wrap">
        <UButton
          icon="i-lucide-arrow-left"
          color="neutral"
          variant="ghost"
          size="lg"
          @click="router.push('/payroll')"
          label="Volver" />
        <div class="flex-1 min-w-0">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white truncate">{{ employee.name }}</h1>
          <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
            Historial detallado de turnos y análisis de desempeño
          </p>
        </div>
        <UButton
          label="Exportar Historial"
          icon="i-lucide-download"
          color="success"
          size="lg"
          @click="exportEmployeeData" />
      </div>

      <!-- HR-Focused Metrics Dashboard (using organism component) -->
      <PayrollOrganismsHRMetricsDashboard
        :metrics="employeeStats"
        :currency="employee.settings.currency" />

      <!-- Detailed History by Week -->
      <div class="space-y-6">
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div class="flex items-center gap-3">
            <div class="p-3 bg-emerald-500/10 rounded-xl">
              <UIcon name="i-lucide-history" class="size-6 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div>
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Historial Detallado de Turnos</h2>
              <p class="text-sm text-gray-600 dark:text-gray-400">Vista día por día de todos los turnos trabajados</p>
            </div>
          </div>
          <UBadge color="primary" variant="subtle" size="lg">
            {{ sortedWeeks.length }} {{ sortedWeeks.length === 1 ? 'semana' : 'semanas' }}
          </UBadge>
        </div>

        <!-- Empty State -->
        <div v-if="sortedWeeks.length === 0" class="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl border-2 border-dashed border-gray-300 dark:border-gray-700">
          <div class="flex flex-col items-center gap-4">
            <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-full">
              <UIcon name="i-lucide-calendar-x" class="size-16 text-gray-400" />
            </div>
            <p class="text-lg text-gray-600 dark:text-gray-400">No hay semanas registradas para este empleado</p>
            <UButton label="Volver a Nóminas" color="primary" @click="router.push('/payroll')" />
          </div>
        </div>

        <!-- Week Cards with Detailed Day Breakdown (using organism component) -->
        <div v-else class="space-y-8">
          <PayrollOrganismsWeekDetailCard
            v-for="week in sortedWeeks"
            :key="week.id"
            :week="week"
            :currency="employee.settings.currency" />
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-else class="flex items-center justify-center min-h-screen">
      <div class="text-center">
        <UIcon name="i-lucide-loader-2" class="size-12 text-emerald-600 animate-spin mx-auto mb-4" />
        <p class="text-gray-600 dark:text-gray-400">Cargando información del empleado...</p>
      </div>
    </div>
  </div>
</template>
