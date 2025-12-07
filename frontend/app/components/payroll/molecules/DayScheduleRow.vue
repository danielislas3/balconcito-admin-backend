<script setup lang="ts">
import type { DaySchedule } from '~/types/payroll'

export interface DayScheduleRowProps {
  dayKey: string
  dayName: string
  dayEmoji: string
  schedule: DaySchedule
  currency?: string
  isActive?: boolean
}

const props = withDefaults(defineProps<DayScheduleRowProps>(), {
  isActive: false
})

const formatTime = (hour: string, minute: string) => {
  if (!hour || !minute) return '--:--'
  return `${hour}:${minute}`
}

const hasDayData = computed(() => {
  return props.schedule.hoursWorked > 0 ||
         (props.schedule.entryHour && props.schedule.exitHour)
})

const formatCurrency = (amount: number) => {
  const symbol = props.currency === 'USD' ? '$' : props.currency === 'EUR' ? '€' : '$'
  return `${symbol}${amount.toFixed(2)}`
}
</script>

<template>
  <div :class="[
    'p-5 rounded-xl border-2 transition-all',
    hasDayData
      ? 'bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-950/20 dark:to-teal-950/20 border-emerald-200 dark:border-emerald-800'
      : 'bg-gray-50 dark:bg-gray-900/30 border-gray-200 dark:border-gray-700',
    isActive && 'ring-2 ring-emerald-500'
  ]">
    <!-- Encabezado: Día y horario -->
    <div class="flex items-center justify-between mb-3">
      <PayrollAtomsDayLabel
        :emoji="dayEmoji"
        :name="dayName"
        :subtitle="formatTime(schedule.entryHour, schedule.entryMinute) + ' → ' + formatTime(schedule.exitHour, schedule.exitMinute)" />

      <div class="text-right">
        <div class="text-xs text-gray-500 dark:text-gray-400">Total del día</div>
        <div class="text-xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
          {{ formatCurrency(schedule.dailyPay) }}
        </div>
      </div>
    </div>

    <!-- Desglose de horas y pagos -->
    <div v-if="hasDayData" class="grid grid-cols-2 md:grid-cols-4 gap-3 mt-4">
      <!-- Total Hours -->
      <div class="text-center p-3 bg-blue-50/80 dark:bg-blue-950/30 rounded-lg">
        <div class="text-sm font-bold text-blue-600 dark:text-blue-400 tabular-nums">
          {{ schedule.hoursWorked.toFixed(1) }}h
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400 mt-0.5">Total</div>
      </div>

      <!-- Regular Hours -->
      <div class="text-center p-3 bg-emerald-50/80 dark:bg-emerald-950/30 rounded-lg">
        <div class="text-sm font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
          {{ schedule.regularHours.toFixed(1) }}h
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400 mt-0.5">Regular</div>
      </div>

      <!-- Overtime Tier 1 -->
      <div v-if="schedule.overtimeHours > 0" class="text-center p-3 bg-amber-50/80 dark:bg-amber-950/30 rounded-lg">
        <div class="text-sm font-bold text-amber-600 dark:text-amber-400 tabular-nums">
          {{ schedule.overtimeHours.toFixed(1) }}h
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400 mt-0.5">Extra T1</div>
      </div>

      <!-- Overtime Tier 2 -->
      <div v-if="schedule.extraHours > 0" class="text-center p-3 bg-red-50/80 dark:bg-red-950/30 rounded-lg">
        <div class="text-sm font-bold text-red-600 dark:text-red-400 tabular-nums">
          {{ schedule.extraHours.toFixed(1) }}h
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400 mt-0.5">Extra T2</div>
      </div>
    </div>

    <!-- Sin datos -->
    <div v-else class="text-center py-2 text-sm text-gray-400 dark:text-gray-500">
      No trabajado
    </div>
  </div>
</template>
