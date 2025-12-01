<script setup lang="ts">
export interface WeekSummaryStatsProps {
  totalHours: number
  totalShifts: number
  totalExtraHours: number
  totalTips: number
  currency?: string
}

const props = defineProps<WeekSummaryStatsProps>()

const formatCurrency = (amount: number) => {
  const symbol = props.currency === 'USD' ? '$' : props.currency === 'EUR' ? '€' : '$'
  return `${symbol}${amount.toFixed(2)}`
}
</script>

<template>
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
    <!-- Total Hours -->
    <div class="text-center p-3 bg-blue-50 dark:bg-blue-950/20 rounded-xl">
      <div class="text-2xl font-bold text-blue-600 dark:text-blue-400 tabular-nums">
        {{ totalHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Total Horas</div>
    </div>

    <!-- Total Shifts -->
    <div class="text-center p-3 bg-emerald-50 dark:bg-emerald-950/20 rounded-xl">
      <div class="text-2xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
        {{ totalShifts }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Turnos Completos</div>
    </div>

    <!-- Extra Hours -->
    <div class="text-center p-3 bg-amber-50 dark:bg-amber-950/20 rounded-xl">
      <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 tabular-nums">
        {{ totalExtraHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Horas Extra</div>
    </div>

    <!-- Tips -->
    <div class="text-center p-3 bg-violet-50 dark:bg-violet-950/20 rounded-xl">
      <div class="text-2xl font-bold text-violet-600 dark:text-violet-400 tabular-nums">
        {{ formatCurrency(totalTips) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Propinas</div>
    </div>
  </div>
</template>
