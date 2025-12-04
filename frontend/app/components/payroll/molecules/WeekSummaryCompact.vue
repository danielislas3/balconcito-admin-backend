<script setup lang="ts">
import type { Week } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'

export interface WeekSummaryCompactProps {
  week: Week
  employeeName: string
  currency?: string
}

const props = defineProps<WeekSummaryCompactProps>()
const payrollStore = usePayrollStore()

const formatWeekDisplay = (dateStr: string) => {
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-ES', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

const formatCurrency = (amount: number) => {
  const symbol = props.currency === 'USD' ? '$' : props.currency === 'EUR' ? '€' : '$'
  return `${symbol}${amount.toFixed(2)}`
}

// Calcular totales de la semana
const weekTotals = payrollStore.calculateWeekTotals(props.week)
</script>

<template>
  <UCard class="bg-gradient-to-br from-gray-50 to-slate-50 dark:from-gray-900 dark:to-slate-900 border-2 border-gray-300 dark:border-gray-700">
    <template #header>
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-receipt" class="size-4 text-gray-600 dark:text-gray-400" />
          <h3 class="text-sm font-semibold text-gray-900 dark:text-white">Resumen Semanal</h3>
        </div>
        <div class="text-xs text-gray-500">{{ employeeName }}</div>
      </div>
    </template>

    <!-- Tabla compacta de días -->
    <div class="space-y-1">
      <div
        v-for="day in payrollStore.days"
        :key="day.key"
        v-show="week.schedule[day.key].hoursWorked > 0"
        class="flex items-center justify-between p-2 rounded bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700">

        <div class="flex items-center gap-2 flex-1">
          <span class="text-sm">{{ day.emoji }}</span>
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300 w-20">{{ day.name }}</span>
          <span class="text-xs text-gray-500 dark:text-gray-400">
            {{ week.schedule[day.key].hoursWorked.toFixed(1) }}h
          </span>
        </div>

        <div class="text-sm font-semibold text-gray-900 dark:text-white tabular-nums">
          {{ formatCurrency(week.schedule[day.key].dailyPay) }}
        </div>
      </div>
    </div>

    <!-- Total de la semana -->
    <div class="mt-3 pt-3 border-t-2 border-gray-300 dark:border-gray-600">
      <div class="flex items-center justify-between p-2 bg-gradient-to-r from-emerald-100 to-teal-100 dark:from-emerald-900/30 dark:to-teal-900/30 rounded-lg">
        <div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Semana del {{ formatWeekDisplay(week.startDate) }}</div>
          <div class="text-sm font-semibold text-gray-700 dark:text-gray-300">
            {{ weekTotals.totalHours.toFixed(1) }}h totales
            <span v-if="week.weeklyTips > 0" class="text-xs text-amber-600 dark:text-amber-400">
              + ${{ week.weeklyTips.toFixed(2) }} propinas
            </span>
          </div>
        </div>
        <div class="text-right">
          <div class="text-lg font-bold text-emerald-700 dark:text-emerald-400 tabular-nums">
            {{ formatCurrency(weekTotals.totalPay + (week.weeklyTips || 0)) }}
          </div>
        </div>
      </div>
    </div>
  </UCard>
</template>
