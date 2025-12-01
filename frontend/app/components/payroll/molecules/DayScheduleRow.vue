<script setup lang="ts">
import type { DaySchedule } from '~/stores/payroll'

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

const getShiftStatus = computed(() => {
  if (!hasDayData.value) {
    return { label: 'Sin datos', color: 'neutral' as const }
  }
  if (props.schedule.completeShifts >= 1) {
    return { label: 'Turno completo', color: 'success' as const }
  }
  if (props.schedule.hoursWorked > 0) {
    return { label: 'Turno parcial', color: 'warning' as const }
  }
  return { label: 'Sin turno', color: 'neutral' as const }
})

const formatCurrency = (amount: number) => {
  const symbol = props.currency === 'USD' ? '$' : props.currency === 'EUR' ? '€' : '$'
  return `${symbol}${amount.toFixed(2)}`
}
</script>

<template>
  <div :class="[
    'p-4 rounded-xl border-2 transition-all',
    hasDayData
      ? 'bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-950/20 dark:to-teal-950/20 border-emerald-200 dark:border-emerald-800'
      : 'bg-gray-50 dark:bg-gray-900/30 border-gray-200 dark:border-gray-700',
    isActive && 'ring-2 ring-emerald-500'
  ]">
    <div class="flex items-center justify-between flex-wrap gap-4">
      <!-- Day Info -->
      <PayrollAtomsDayLabel
        :emoji="dayEmoji"
        :name="dayName"
        :subtitle="formatTime(schedule.entryHour, schedule.entryMinute) + ' - ' + formatTime(schedule.exitHour, schedule.exitMinute)" />

      <!-- Day Stats -->
      <div class="flex items-center gap-3 flex-wrap">
        <!-- Hours Worked -->
        <PayrollAtomsInlineStat
          icon="i-lucide-clock"
          :value="`${schedule.hoursWorked.toFixed(1)}h`"
          color="blue"
          size="md" />

        <!-- Complete Shifts -->
        <PayrollAtomsInlineStat
          icon="i-lucide-briefcase"
          :value="`${schedule.completeShifts} turno${schedule.completeShifts !== 1 ? 's' : ''}`"
          color="emerald"
          size="md" />

        <!-- Extra Hours (only if > 0) -->
        <PayrollAtomsInlineStat
          v-if="schedule.extraHours > 0"
          icon="i-lucide-clock-alert"
          :value="`+${schedule.extraHours.toFixed(1)}h extra`"
          color="amber"
          size="md" />

        <!-- Daily Pay -->
        <PayrollAtomsInlineStat
          icon="i-lucide-wallet"
          :value="formatCurrency(schedule.dailyPay)"
          color="violet"
          size="md" />

        <!-- Status Badge -->
        <UBadge
          :color="getShiftStatus.color"
          variant="subtle"
          size="md">
          {{ getShiftStatus.label }}
        </UBadge>
      </div>
    </div>
  </div>
</template>
