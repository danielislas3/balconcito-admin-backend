<script setup lang="ts">
export interface WeekSummaryStatsProps {
  totalHours: number
  regularHours: number
  overtimeHours1: number
  overtimeHours2: number
  totalShifts: number          // Deprecated pero mantenido para compatibilidad
  totalExtraHours: number      // Deprecated pero mantenido para compatibilidad
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

    <!-- Overtime Hours Tier 1 (1.5x) -->
    <div class="text-center p-3 bg-amber-50 dark:bg-amber-950/20 rounded-xl">
      <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 tabular-nums">
        {{ overtimeHours1.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Hrs Extra</div>
      <div class="text-xs text-amber-600 dark:text-amber-400 font-semibold">150%</div>
    </div>

    <!-- Overtime Hours Tier 2 (2x) -->
    <div class="text-center p-3 bg-red-50 dark:bg-red-950/20 rounded-xl">
      <div class="text-2xl font-bold text-red-600 dark:text-red-400 tabular-nums">
        {{ overtimeHours2.toFixed(1) }}
      </div>
      <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">Hrs Extra</div>
      <div class="text-xs text-red-600 dark:text-red-400 font-semibold">200%</div>
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
