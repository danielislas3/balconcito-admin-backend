<script setup lang="ts">
import { formatCurrency } from '~/utils/payrollFormatters'

export interface WeeklySummaryCardsProps {
  totalHours: number
  totalShifts: number
  totalExtraHours: number
  totalPay: number
}

const props = defineProps<WeeklySummaryCardsProps>()
</script>

<template>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    <!-- Total Horas -->
    <div
      class="group relative bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950 dark:to-indigo-950 rounded-2xl p-6 border-2 border-blue-100 dark:border-blue-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
      <div
        class="absolute top-0 right-0 w-32 h-32 bg-blue-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500">
      </div>
      <div class="relative">
        <div class="flex items-center justify-between mb-4">
          <div class="p-3 bg-blue-500/10 rounded-xl group-hover:bg-blue-500/20 transition-colors">
            <UIcon name="i-lucide-clock" class="size-6 text-blue-600 dark:text-blue-400" />
          </div>
        </div>
        <div class="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-1 tabular-nums">
          {{ totalHours.toFixed(1) }}
        </div>
        <div class="text-sm font-medium text-blue-600 dark:text-blue-400 uppercase tracking-wider">Total Horas
        </div>
      </div>
    </div>

    <!-- Turnos Completos -->
    <div
      class="group relative bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-950 dark:to-teal-950 rounded-2xl p-6 border-2 border-emerald-100 dark:border-emerald-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
      <div
        class="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500">
      </div>
      <div class="relative">
        <div class="flex items-center justify-between mb-4">
          <div class="p-3 bg-emerald-500/10 rounded-xl group-hover:bg-emerald-500/20 transition-colors">
            <UIcon name="i-lucide-briefcase" class="size-6 text-emerald-600 dark:text-emerald-400" />
          </div>
        </div>
        <div class="text-4xl font-bold text-emerald-900 dark:text-emerald-100 mb-1 tabular-nums">
          {{ totalShifts }}
        </div>
        <div class="text-sm font-medium text-emerald-600 dark:text-emerald-400 uppercase tracking-wider">Turnos
          Completos
        </div>
      </div>
    </div>

    <!-- Horas Extra -->
    <div
      class="group relative bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950 dark:to-orange-950 rounded-2xl p-6 border-2 border-amber-100 dark:border-amber-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
      <div
        class="absolute top-0 right-0 w-32 h-32 bg-amber-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500">
      </div>
      <div class="relative">
        <div class="flex items-center justify-between mb-4">
          <div class="p-3 bg-amber-500/10 rounded-xl group-hover:bg-amber-500/20 transition-colors">
            <UIcon name="i-lucide-clock-alert" class="size-6 text-amber-600 dark:text-amber-400" />
          </div>
        </div>
        <div class="text-4xl font-bold text-amber-900 dark:text-amber-100 mb-1 tabular-nums">
          {{ totalExtraHours.toFixed(1) }}
        </div>
        <div class="text-sm font-medium text-amber-600 dark:text-amber-400 uppercase tracking-wider">Horas Extra
        </div>
      </div>
    </div>

    <!-- Pago Total -->
    <div
      class="group relative bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950 dark:to-purple-950 rounded-2xl p-6 border-2 border-violet-100 dark:border-violet-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
      <div
        class="absolute top-0 right-0 w-32 h-32 bg-violet-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500">
      </div>
      <div class="relative">
        <div class="flex items-center justify-between mb-4">
          <div class="p-3 bg-violet-500/10 rounded-xl group-hover:bg-violet-500/20 transition-colors">
            <UIcon name="i-lucide-banknote" class="size-6 text-violet-600 dark:text-violet-400" />
          </div>
        </div>
        <div class="text-3xl font-bold text-violet-900 dark:text-violet-100 mb-1 tabular-nums">
          {{ formatCurrency(totalPay, 'MXN') }}
        </div>
        <div class="text-sm font-medium text-violet-600 dark:text-violet-400 uppercase tracking-wider">Pago
          Total</div>
      </div>
    </div>
  </div>
</template>
