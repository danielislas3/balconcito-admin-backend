<script setup lang="ts">
import type { Week, WeekSchedule } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'

export interface WeekDetailCardProps {
  week: Week
  currency?: string
}

const props = defineProps<WeekDetailCardProps>()
const payrollStore = usePayrollStore()

const weekTotals = computed(() => payrollStore.calculateWeekTotals(props.week))

const formatWeekDisplay = (dateStr: string) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

const formatMonth = (dateStr: string) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-MX', { year: 'numeric', month: 'long' })
}

const formatCurrency = (amount: number) => {
  const symbol = props.currency === 'USD' ? '$' : props.currency === 'EUR' ? '€' : '$'
  return `${symbol}${amount.toFixed(2)}`
}
</script>

<template>
  <UCard class="bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-all duration-300 border-2 border-gray-200 dark:border-gray-700">
    <template #header>
      <div class="flex items-center justify-between flex-wrap gap-4">
        <div class="flex items-center gap-3">
          <div class="p-2 bg-emerald-500/10 rounded-lg">
            <UIcon name="i-lucide-calendar" class="size-5 text-emerald-600 dark:text-emerald-400" />
          </div>
          <div>
            <h3 class="text-xl font-bold text-gray-900 dark:text-white">
              Semana del {{ formatWeekDisplay(week.startDate) }}
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-400 mt-0.5">
              {{ formatMonth(week.startDate) }}
            </p>
          </div>
        </div>
        <div class="text-right">
          <div class="text-sm text-gray-500 dark:text-gray-400">Total Semanal</div>
          <div class="text-2xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
            {{ formatCurrency(weekTotals.totalPay) }}
          </div>
        </div>
      </div>
    </template>

    <!-- Week Summary Stats -->
    <PayrollMoleculesWeekSummaryStats
      :total-hours="weekTotals.totalHours"
      :regular-hours="weekTotals.regularHours"
      :overtime-hours1="weekTotals.overtimeHours1"
      :overtime-hours2="weekTotals.overtimeHours2"
      :total-shifts="weekTotals.totalShifts"
      :total-extra-hours="weekTotals.totalExtraHours"
      :total-tips="week.weeklyTips || 0"
      :currency="currency"
      class="mb-6 pb-6 border-b border-gray-200 dark:border-gray-700" />

    <!-- Detailed Day-by-Day Breakdown -->
    <div class="space-y-3 mb-6">
      <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-3">
        Desglose Diario
      </h4>

      <PayrollMoleculesDayScheduleRow
        v-for="day in payrollStore.days"
        :key="day.key"
        :day-key="day.key"
        :day-name="day.name"
        :day-emoji="day.emoji"
        :schedule="week.schedule[day.key as keyof WeekSchedule]"
        :currency="currency" />
    </div>

    <!-- Resumen de Pago Semanal (Screenshot-friendly) -->
    <div class="mt-6 p-6 bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 rounded-2xl border-2 border-violet-200 dark:border-violet-800">
      <div class="flex items-center gap-3 mb-5">
        <div class="p-2 bg-violet-500/10 rounded-lg">
          <UIcon name="i-lucide-receipt" class="size-6 text-violet-600 dark:text-violet-400" />
        </div>
        <h3 class="text-lg font-bold text-gray-900 dark:text-white">Resumen de Pago Semanal</h3>
      </div>

      <!-- Desglose de Pagos -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">
        <!-- Pago Regular -->
        <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Regulares</div>
              <div class="text-sm font-semibold text-emerald-600 dark:text-emerald-400">
                {{ weekTotals.regularHours.toFixed(1) }}h × 100%
              </div>
            </div>
            <div class="text-right">
              <div class="text-lg font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
                {{ formatCurrency(weekTotals.regularPay) }}
              </div>
            </div>
          </div>
        </div>

        <!-- Pago Extra 1.5x -->
        <div v-if="weekTotals.overtimeHours1 > 0" class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Extra (1.5x)</div>
              <div class="text-sm font-semibold text-amber-600 dark:text-amber-400">
                {{ weekTotals.overtimeHours1.toFixed(1) }}h × 150%
              </div>
            </div>
            <div class="text-right">
              <div class="text-lg font-bold text-amber-600 dark:text-amber-400 tabular-nums">
                {{ formatCurrency(weekTotals.overtimePay1) }}
              </div>
            </div>
          </div>
        </div>

        <!-- Pago Extra 2x -->
        <div v-if="weekTotals.overtimeHours2 > 0" class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Extra (2x)</div>
              <div class="text-sm font-semibold text-red-600 dark:text-red-400">
                {{ weekTotals.overtimeHours2.toFixed(1) }}h × 200%
              </div>
            </div>
            <div class="text-right">
              <div class="text-lg font-bold text-red-600 dark:text-red-400 tabular-nums">
                {{ formatCurrency(weekTotals.overtimePay2) }}
              </div>
            </div>
          </div>
        </div>

        <!-- Propinas -->
        <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Propinas</div>
              <div class="text-sm font-semibold text-violet-600 dark:text-violet-400">
                Semana completa
              </div>
            </div>
            <div class="text-right">
              <div class="text-lg font-bold text-violet-600 dark:text-violet-400 tabular-nums">
                {{ formatCurrency(week.weeklyTips || 0) }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Total Final -->
      <div class="pt-5 border-t-2 border-violet-200 dark:border-violet-700">
        <div class="flex items-center justify-between">
          <div>
            <div class="text-sm text-gray-600 dark:text-gray-400">Total a Pagar</div>
            <div class="text-xs text-gray-500 dark:text-gray-500 mt-1">
              Semana del {{ formatWeekDisplay(week.startDate) }}
            </div>
          </div>
          <div class="text-right">
            <div class="text-3xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
              {{ formatCurrency(weekTotals.totalPay) }}
            </div>
            <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">
              {{ weekTotals.totalHours.toFixed(1) }} horas totales
            </div>
          </div>
        </div>
      </div>
    </div>
  </UCard>
</template>
