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
      :total-shifts="weekTotals.totalShifts"
      :total-extra-hours="weekTotals.totalExtraHours"
      :total-tips="week.weeklyTips || 0"
      :currency="currency"
      class="mb-6 pb-6 border-b border-gray-200 dark:border-gray-700" />

    <!-- Detailed Day-by-Day Breakdown -->
    <div class="space-y-3">
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
  </UCard>
</template>
