<script setup lang="ts">
import type { PayrollWeek, WeekSchedule } from '~/types/payroll'
import { calculateWeekTotals } from '~/utils/payrollCalculations'
import { formatCurrency as formatCurrencyUtil, formatWeekDisplay, formatMonthDisplay } from '~/utils/payrollFormatters'
import { WEEK_DAYS } from '~/utils/payrollConstants'

export interface WeekDetailCardProps {
  week: PayrollWeek
  currency?: string
}

const props = defineProps<WeekDetailCardProps>()

const weekTotals = computed(() => calculateWeekTotals(props.week))

const formatMonth = (dateStr: string) => {
  return formatMonthDisplay(dateStr)
}

const formatCurrency = (amount: number = 0) => {
  return formatCurrencyUtil(amount, (props.currency || 'MXN') as any)
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
      :overtime-hours="weekTotals.overtimeHours"
      :extra-hours="weekTotals.extraHours"
      :total-tips="week.weeklyTips || 0"
      :currency="currency"
      class="mb-6 pb-6 border-b border-gray-200 dark:border-gray-700" />

    <!-- Detailed Day-by-Day Breakdown -->
    <div class="space-y-3 mb-6">
      <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider mb-3">
        Desglose Diario
      </h4>

      <PayrollMoleculesDayScheduleRow
        v-for="day in WEEK_DAYS"
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
        <!-- Horas Regulares -->
        <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Regulares</div>
              <div class="text-sm font-semibold text-emerald-600 dark:text-emerald-400">
                {{ weekTotals.regularHours.toFixed(1) }}h × 100%
              </div>
            </div>
          </div>
        </div>

        <!-- Horas Extra Tier 1 -->
        <div v-if="weekTotals.overtimeHours > 0" class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Extra (Tier 1)</div>
              <div class="text-sm font-semibold text-amber-600 dark:text-amber-400">
                {{ weekTotals.overtimeHours.toFixed(1) }}h
              </div>
            </div>
          </div>
        </div>

        <!-- Horas Extra Tier 2 -->
        <div v-if="weekTotals.extraHours > 0" class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Horas Extra (Tier 2)</div>
              <div class="text-sm font-semibold text-red-600 dark:text-red-400">
                {{ weekTotals.extraHours.toFixed(1) }}h
              </div>
            </div>
          </div>
        </div>

        <!-- Pago Base -->
        <div class="p-4 bg-white/80 dark:bg-gray-800/80 rounded-xl">
          <div class="flex items-center justify-between">
            <div>
              <div class="text-xs text-gray-500 dark:text-gray-400">Pago Base</div>
              <div class="text-sm font-semibold text-emerald-600 dark:text-emerald-400">
                Total de horas trabajadas
              </div>
            </div>
            <div class="text-right">
              <div class="text-lg font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
                {{ formatCurrency(weekTotals.totalBasePay) }}
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
