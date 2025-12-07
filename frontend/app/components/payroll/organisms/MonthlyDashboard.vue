<script setup lang="ts">
import { usePayrollStore } from '~/stores/payroll'

const payrollStore = usePayrollStore()
const dayjs = useDayjs()

// Estado para selección de mes
const selectedYear = ref<number>(dayjs().year())
const selectedMonth = ref<number>(dayjs().month())

// Obtener meses disponibles
const availableMonths = computed(() => payrollStore.getAvailableMonths())

// Calcular estadísticas del mes seleccionado
const monthlyStats = computed(() => {
  return payrollStore.calculateMonthlyStats(selectedYear.value, selectedMonth.value)
})

// Formato de moneda (siempre MXN)
const formatCurrency = (amount: number | undefined) => {
  const value = amount ?? 0
  return `$${value.toFixed(2)}`
}

// Formato de fecha
const formatWeekDisplay = (dateStr: string) => {
  return dayjs(dateStr).format('DD/MM/YYYY')
}

// Nombre del mes actual
const currentMonthLabel = computed(() => {
  return dayjs().year(selectedYear.value).month(selectedMonth.value).format('MMMM YYYY')
})

// Auto-seleccionar el mes más reciente si hay datos
watchEffect(() => {
  if (availableMonths.value.length > 0 && !monthlyStats.value) {
    const latest = availableMonths.value[0]
    selectedYear.value = latest.year
    selectedMonth.value = latest.month
  }
})
</script>

<template>
  <div class="space-y-6">
    <!-- Month Selector -->
    <UCard v-if="availableMonths.length > 0">
      <template #header>
        <div class="flex items-center gap-3">
          <div class="p-2 bg-violet-500/10 rounded-lg">
            <UIcon name="i-lucide-calendar-range" class="size-5 text-violet-600 dark:text-violet-400" />
          </div>
          <div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Resumen Mensual</h3>
            <p class="text-sm text-gray-600 dark:text-gray-400">
              Selecciona un mes para ver las métricas
            </p>
          </div>
        </div>
      </template>

      <div class="flex flex-wrap gap-2">
        <button
          v-for="month in availableMonths"
          :key="`${month.year}-${month.month}`"
          @click="() => { selectedYear = month.year; selectedMonth = month.month }"
          :class="[
            'px-4 py-2 rounded-lg text-sm font-medium transition-all',
            selectedYear === month.year && selectedMonth === month.month
              ? 'bg-violet-600 text-white shadow-md'
              : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
          ]">
          {{ month.label }}
        </button>
      </div>
    </UCard>

    <!-- Empty State -->
    <div v-if="!monthlyStats" class="text-center py-12">
      <div class="p-4 bg-gray-100 dark:bg-gray-800 rounded-full inline-block mb-4">
        <UIcon name="i-lucide-calendar-x" class="size-12 text-gray-400" />
      </div>
      <h3 class="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-2">
        No hay datos disponibles
      </h3>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        Agrega semanas de trabajo para ver las métricas mensuales
      </p>
    </div>

    <!-- Monthly Stats Dashboard -->
    <div v-else class="space-y-6">
      <!-- Header Card -->
      <UCard class="bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 border-2 border-violet-200 dark:border-violet-800">
        <div class="text-center">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">
            {{ currentMonthLabel }}
          </h2>
          <div class="text-5xl font-bold text-violet-600 dark:text-violet-400 mb-2">
            {{ formatCurrency(monthlyStats.totalPay) }}
          </div>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Total pagado en el mes
          </p>
        </div>
      </UCard>

      <!-- Key Metrics Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Total Hours -->
        <UCard>
          <div class="text-center">
            <div class="p-3 bg-blue-50 dark:bg-blue-950/20 rounded-xl inline-block mb-3">
              <UIcon name="i-lucide-clock" class="size-8 text-blue-600 dark:text-blue-400" />
            </div>
            <div class="text-3xl font-bold text-blue-600 dark:text-blue-400 tabular-nums">
              {{ (monthlyStats.totalHours ?? 0).toFixed(1) }}
            </div>
            <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">Total Horas</div>
          </div>
        </UCard>

        <!-- Weeks Count -->
        <UCard>
          <div class="text-center">
            <div class="p-3 bg-emerald-50 dark:bg-emerald-950/20 rounded-xl inline-block mb-3">
              <UIcon name="i-lucide-calendar-days" class="size-8 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div class="text-3xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
              {{ monthlyStats.weeksCount ?? 0 }}
            </div>
            <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">Semanas</div>
          </div>
        </UCard>

        <!-- Average Hours/Week -->
        <UCard>
          <div class="text-center">
            <div class="p-3 bg-amber-50 dark:bg-amber-950/20 rounded-xl inline-block mb-3">
              <UIcon name="i-lucide-trending-up" class="size-8 text-amber-600 dark:text-amber-400" />
            </div>
            <div class="text-3xl font-bold text-amber-600 dark:text-amber-400 tabular-nums">
              {{ (monthlyStats.avgHoursPerWeek ?? 0).toFixed(1) }}
            </div>
            <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">Hrs/Semana</div>
          </div>
        </UCard>

        <!-- Total Tips -->
        <UCard>
          <div class="text-center">
            <div class="p-3 bg-violet-50 dark:bg-violet-950/20 rounded-xl inline-block mb-3">
              <UIcon name="i-lucide-coins" class="size-8 text-violet-600 dark:text-violet-400" />
            </div>
            <div class="text-2xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
              {{ formatCurrency(monthlyStats.totalTips) }}
            </div>
            <div class="text-sm text-gray-600 dark:text-gray-400 mt-1">Propinas</div>
          </div>
        </UCard>
      </div>

      <!-- Hours Breakdown -->
      <UCard>
        <template #header>
          <div class="flex items-center gap-3">
            <div class="p-2 bg-emerald-500/10 rounded-lg">
              <UIcon name="i-lucide-bar-chart-3" class="size-5 text-emerald-600 dark:text-emerald-400" />
            </div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Desglose de Horas</h3>
          </div>
        </template>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <!-- Regular Hours -->
          <div class="p-4 bg-emerald-50 dark:bg-emerald-950/20 rounded-xl">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Horas Regulares</div>
            <div class="text-3xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
              {{ (monthlyStats.regularHours ?? 0).toFixed(1) }}h
            </div>
            <div class="text-xs text-emerald-600 dark:text-emerald-400 font-semibold mt-1">
              100%
            </div>
          </div>

          <!-- Overtime Tier 1 -->
          <div class="p-4 bg-amber-50 dark:bg-amber-950/20 rounded-xl">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Horas Extra Tier 1</div>
            <div class="text-3xl font-bold text-amber-600 dark:text-amber-400 tabular-nums">
              {{ (monthlyStats.overtimeHours ?? 0).toFixed(1) }}h
            </div>
            <div class="text-xs text-amber-600 dark:text-amber-400 font-semibold mt-1">
              Tier 1
            </div>
          </div>

          <!-- Overtime Tier 2 -->
          <div class="p-4 bg-red-50 dark:bg-red-950/20 rounded-xl">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Horas Extra Tier 2</div>
            <div class="text-3xl font-bold text-red-600 dark:text-red-400 tabular-nums">
              {{ (monthlyStats.extraHours ?? 0).toFixed(1) }}h
            </div>
            <div class="text-xs text-red-600 dark:text-red-400 font-semibold mt-1">
              Tier 2
            </div>
          </div>
        </div>
      </UCard>

      <!-- Weekly Breakdown -->
      <UCard>
        <template #header>
          <div class="flex items-center gap-3">
            <div class="p-2 bg-blue-500/10 rounded-lg">
              <UIcon name="i-lucide-list" class="size-5 text-blue-600 dark:text-blue-400" />
            </div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Semanas del Mes</h3>
          </div>
        </template>

        <div class="space-y-3">
          <div
            v-for="week in monthlyStats.weeks"
            :key="week.id"
            class="p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg border border-gray-200 dark:border-gray-700 hover:border-violet-300 dark:hover:border-violet-700 transition-colors">
            <div class="flex items-center justify-between flex-wrap gap-3">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-violet-500/10 rounded-lg">
                  <UIcon name="i-lucide-calendar" class="size-5 text-violet-600 dark:text-violet-400" />
                </div>
                <div>
                  <div class="font-semibold text-gray-900 dark:text-white">
                    Semana del {{ formatWeekDisplay(week.startDate) }}
                  </div>
                  <div class="text-sm text-gray-600 dark:text-gray-400">
                    {{ (payrollStore.calculateWeekTotals(week).totalHours ?? 0).toFixed(1) }} horas trabajadas
                  </div>
                </div>
              </div>
              <div class="text-right">
                <div class="text-xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
                  {{ formatCurrency(payrollStore.calculateWeekTotals(week).totalPay) }}
                </div>
                <div v-if="week.weeklyTips > 0" class="text-sm text-gray-600 dark:text-gray-400">
                  Incluye {{ formatCurrency(week.weeklyTips) }} en propinas
                </div>
              </div>
            </div>
          </div>
        </div>
      </UCard>

      <!-- Payment Summary Card -->
      <UCard class="bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 border-2 border-violet-200 dark:border-violet-800">
        <template #header>
          <div class="flex items-center gap-3">
            <div class="p-2 bg-violet-500/10 rounded-lg">
              <UIcon name="i-lucide-receipt" class="size-5 text-violet-600 dark:text-violet-400" />
            </div>
            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Resumen de Pago Total</h3>
          </div>
        </template>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Pago Base -->
          <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Pago por Horas</div>
            <div class="text-2xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
              {{ formatCurrency(monthlyStats.totalBasePay) }}
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-500 mt-1">
              {{ (monthlyStats.totalHours ?? 0).toFixed(1) }} horas totales
            </div>
          </div>

          <!-- Propinas -->
          <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">Propinas del Mes</div>
            <div class="text-2xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
              {{ formatCurrency(monthlyStats.totalTips) }}
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-500 mt-1">
              {{ monthlyStats.weeksCount }} semanas
            </div>
          </div>
        </div>

        <div class="pt-4 border-t-2 border-violet-200 dark:border-violet-700 mt-4">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-sm text-gray-600 dark:text-gray-400">Pago Total del Mes</div>
              <div class="text-xs text-gray-500 dark:text-gray-500 mt-1">
                {{ currentMonthLabel }}
              </div>
            </div>
            <div class="text-right">
              <div class="text-3xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
                {{ formatCurrency(monthlyStats.totalPay) }}
              </div>
              <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                Promedio: {{ formatCurrency(monthlyStats.avgPayPerWeek) }}/semana
              </div>
            </div>
          </div>
        </div>
      </UCard>
    </div>
  </div>
</template>
