<script setup lang="ts">
import type { Week, WeekSchedule } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'

export interface ScheduleTableProps {
  week: Week
  employeeName: string
}

const props = defineProps<ScheduleTableProps>()
const payrollStore = usePayrollStore()

const formatDate = (dateStr: string) => {
  return payrollStore.formatWeekDisplay(dateStr)
}
</script>

<template>
  <UCard
    class="bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-emerald-100 dark:border-emerald-900">
    <template #header>
      <div>
        <div class="flex items-center gap-2 mb-1">
          <UIcon name="i-lucide-calendar-clock" class="size-5 text-success-600" />
          <h2 class="text-lg font-semibold">Horarios - {{ employeeName }}</h2>
        </div>
        <p class="text-sm text-gray-500">Semana del {{ formatDate(week.startDate) }}</p>
      </div>
    </template>

    <div class="overflow-x-auto">
      <table class="w-full border-separate border-spacing-0 text-sm">
        <thead>
          <tr class="bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-950/50 dark:to-teal-950/50">
            <th
              class="px-4 py-3 text-left font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800 rounded-tl-xl">
              Día</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800">
              Hora Entrada</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800">
              Hora Salida</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800">
              Horas</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800">
              Turnos</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800">
              Extra</th>
            <th
              class="px-4 py-3 text-center font-semibold text-gray-700 dark:text-gray-300 border-b-2 border-emerald-200 dark:border-emerald-800 rounded-tr-xl">
              Pago</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="day in payrollStore.days" :key="day.key"
            class="group hover:bg-emerald-50/50 dark:hover:bg-emerald-950/20 transition-colors">
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700">
              <div class="flex items-center gap-2">
                <span class="text-2xl">{{ day.emoji }}</span>
                <span class="font-medium text-gray-900 dark:text-white">{{ day.name }}</span>
              </div>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700">
              <div class="flex items-center justify-center gap-1">
                <select :value="week.schedule[day.key as keyof WeekSchedule].entryHour" @change="(e) => {
                  week.schedule[day.key as keyof WeekSchedule].entryHour = (e.target as HTMLSelectElement).value;
                  payrollStore.calculateDay(day.key as keyof WeekSchedule);
                }"
                  class="px-2 py-1.5 bg-white dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-900 dark:text-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all">
                  <option value="">--</option>
                  <option v-for="hour in payrollStore.hours" :key="hour" :value="hour">{{ hour }}</option>
                </select>
                <span class="text-lg font-bold text-gray-400">:</span>
                <select :value="week.schedule[day.key as keyof WeekSchedule].entryMinute" @change="(e) => {
                  week.schedule[day.key as keyof WeekSchedule].entryMinute = (e.target as HTMLSelectElement).value;
                  payrollStore.calculateDay(day.key as keyof WeekSchedule);
                }"
                  class="px-2 py-1.5 bg-white dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-900 dark:text-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all">
                  <option value="">--</option>
                  <option value="00">00</option>
                  <option value="15">15</option>
                  <option value="30">30</option>
                  <option value="45">45</option>
                </select>
              </div>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700">
              <div class="flex items-center justify-center gap-1">
                <select :value="week.schedule[day.key as keyof WeekSchedule].exitHour" @change="(e) => {
                  week.schedule[day.key as keyof WeekSchedule].exitHour = (e.target as HTMLSelectElement).value;
                  payrollStore.calculateDay(day.key as keyof WeekSchedule);
                }"
                  class="px-2 py-1.5 bg-white dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-900 dark:text-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all">
                  <option value="">--</option>
                  <option v-for="hour in payrollStore.hours" :key="hour" :value="hour">{{ hour }}</option>
                </select>
                <span class="text-lg font-bold text-gray-400">:</span>
                <select :value="week.schedule[day.key as keyof WeekSchedule].exitMinute" @change="(e) => {
                  week.schedule[day.key as keyof WeekSchedule].exitMinute = (e.target as HTMLSelectElement).value;
                  payrollStore.calculateDay(day.key as keyof WeekSchedule);
                }"
                  class="px-2 py-1.5 bg-white dark:bg-gray-700 border-2 border-gray-300 dark:border-gray-600 rounded-lg text-sm font-medium text-gray-900 dark:text-white focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all">
                  <option value="">--</option>
                  <option value="00">00</option>
                  <option value="15">15</option>
                  <option value="30">30</option>
                  <option value="45">45</option>
                </select>
              </div>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700 text-center">
              <div class="flex items-center justify-center gap-1">
                <span class="text-lg font-bold text-blue-600 dark:text-blue-400 tabular-nums">
                  {{ week.schedule[day.key as keyof WeekSchedule].hoursWorked.toFixed(1) }}
                </span>
                <span class="text-xs text-gray-500 dark:text-gray-400">hrs</span>
              </div>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700 text-center">
              <span
                class="inline-flex items-center justify-center px-3 py-1 bg-emerald-100 dark:bg-emerald-900/30 rounded-lg text-lg font-bold text-emerald-700 dark:text-emerald-300 tabular-nums">
                {{ week.schedule[day.key as keyof WeekSchedule].completeShifts }}
              </span>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700 text-center">
              <span class="text-lg font-bold text-amber-600 dark:text-amber-400 tabular-nums">
                {{ week.schedule[day.key as keyof WeekSchedule].extraHours.toFixed(1) }}
              </span>
            </td>
            <td class="px-4 py-4 border-b border-gray-200 dark:border-gray-700 text-center">
              <span class="text-lg font-bold text-violet-600 dark:text-violet-400 tabular-nums">
                {{ payrollStore.formatCurrency(week.schedule[day.key as keyof WeekSchedule].dailyPay) }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </UCard>
</template>
