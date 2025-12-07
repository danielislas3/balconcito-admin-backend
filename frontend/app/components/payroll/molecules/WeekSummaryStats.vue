<script setup lang="ts">
export interface WeekSummaryStatsProps {
  totalHours: number
  regularHours: number
  overtimeHours: number  // Tier 1 overtime
  extraHours: number     // Tier 2 overtime
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
  <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
    <!-- Total Hours -->
    <div class="text-center p-3 bg-blue-50 dark:bg-blue-950/20 rounded-xl">
      <div class="text-2xl font-bold text-blue-600 dark:text-blue-400 tabular-nums">
        {{ totalHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Total Horas</div>
    </div>

    <!-- Regular Hours -->
    <div class="text-center p-3 bg-emerald-50 dark:bg-emerald-950/20 rounded-xl">
      <div class="text-2xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
        {{ regularHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Hrs Regulares</div>
      <div class="text-xs text-emerald-600 dark:text-emerald-400 font-semibold">100%</div>
    </div>

    <!-- Overtime Hours Tier 1 -->
    <div class="text-center p-3 bg-amber-50 dark:bg-amber-950/20 rounded-xl">
      <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 tabular-nums">
        {{ overtimeHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Hrs Extra T1</div>
      <div class="text-xs text-amber-600 dark:text-amber-400 font-semibold">Tier 1</div>
    </div>

    <!-- Overtime Hours Tier 2 -->
    <div class="text-center p-3 bg-red-50 dark:bg-red-950/20 rounded-xl">
      <div class="text-2xl font-bold text-red-600 dark:text-red-400 tabular-nums">
        {{ extraHours.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Hrs Extra T2</div>
      <div class="text-xs text-red-600 dark:text-red-400 font-semibold">Tier 2</div>
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
