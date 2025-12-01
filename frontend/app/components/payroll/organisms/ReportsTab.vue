<script setup lang="ts">
import type { Employee } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'

const emit = defineEmits<{
  'export-all': []
  'export-employee': [employee: Employee]
  'view-employee': [employeeId: string]
}>()

const payrollStore = usePayrollStore()
const { employees } = storeToRefs(payrollStore)
</script>

<template>
  <div class="w-full space-y-6">
    <!-- Header Section -->
    <div
      class="flex items-center justify-between bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-950/50 dark:to-teal-950/50 p-6 rounded-2xl border-2 border-emerald-100 dark:border-emerald-900">
      <div class="flex items-center gap-3">
        <div class="p-3 bg-emerald-500/10 rounded-xl">
          <UIcon name="i-lucide-bar-chart-3" class="size-6 text-emerald-600 dark:text-emerald-400" />
        </div>
        <div>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white">Reportes por Empleado</h2>
          <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">Estadísticas y análisis de desempeño</p>
        </div>
      </div>
      <UButton v-if="employees.length > 0" label="Exportar Reporte General" icon="i-lucide-download" color="success"
        size="lg" @click="emit('export-all')" />
    </div>

    <!-- Empty State -->
    <div v-if="employees.length === 0"
      class="text-center py-16 bg-white dark:bg-gray-800 rounded-2xl border-2 border-dashed border-gray-300 dark:border-gray-700">
      <div class="flex flex-col items-center gap-4">
        <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-full">
          <UIcon name="i-lucide-bar-chart-3" class="size-16 text-gray-400" />
        </div>
        <p class="text-lg text-gray-600 dark:text-gray-400">No hay empleados registrados para mostrar reportes</p>
      </div>
    </div>

    <!-- Employee Cards Grid -->
    <div v-else class="w-full grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="employee in employees" :key="employee.id"
        class="group relative bg-white dark:bg-gray-800 rounded-2xl border-2 border-gray-200 dark:border-gray-700 hover:border-emerald-400 dark:hover:border-emerald-600 shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden">

        <!-- Gradient Background Accent -->
        <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-emerald-500 via-teal-500 to-cyan-500">
        </div>

        <!-- Card Content -->
        <div class="p-6 space-y-6">
          <!-- Employee Header -->
          <div class="flex items-center gap-4 pb-4 border-b-2 border-gray-100 dark:border-gray-700">
            <div
              class="p-4 bg-gradient-to-br from-emerald-100 to-teal-100 dark:from-emerald-900/30 dark:to-teal-900/30 rounded-xl group-hover:scale-110 transition-transform duration-300">
              <UIcon name="i-lucide-user-circle" class="size-8 text-emerald-600 dark:text-emerald-400" />
            </div>
            <div class="flex-1">
              <h3 class="text-xl font-bold text-gray-900 dark:text-white">{{ employee.name }}</h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                {{ employee.weeks.length }} {{ employee.weeks.length === 1 ? 'semana' : 'semanas' }} registradas
              </p>
            </div>
          </div>

          <!-- Stats Grid -->
          <div class="space-y-4">
            <!-- Total Horas -->
            <div
              class="flex items-center justify-between p-4 bg-blue-50 dark:bg-blue-950/20 rounded-xl hover:bg-blue-100 dark:hover:bg-blue-950/30 transition-colors">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-blue-500/10 rounded-lg">
                  <UIcon name="i-lucide-clock" class="size-5 text-blue-600 dark:text-blue-400" />
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Total Horas</span>
              </div>
              <span class="text-xl font-bold text-blue-600 dark:text-blue-400 tabular-nums">
                {{ payrollStore.calculateEmployeeStats(employee).totalHours.toFixed(1) }}
              </span>
            </div>

            <!-- Total Turnos -->
            <div
              class="flex items-center justify-between p-4 bg-emerald-50 dark:bg-emerald-950/20 rounded-xl hover:bg-emerald-100 dark:hover:bg-emerald-950/30 transition-colors">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-emerald-500/10 rounded-lg">
                  <UIcon name="i-lucide-briefcase" class="size-5 text-emerald-600 dark:text-emerald-400" />
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Total Turnos</span>
              </div>
              <span class="text-xl font-bold text-emerald-600 dark:text-emerald-400 tabular-nums">
                {{ payrollStore.calculateEmployeeStats(employee).totalShifts }}
              </span>
            </div>

            <!-- Promedio Semanal -->
            <div
              class="flex items-center justify-between p-4 bg-purple-50 dark:bg-purple-950/20 rounded-xl hover:bg-purple-100 dark:hover:bg-purple-950/30 transition-colors">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-purple-500/10 rounded-lg">
                  <UIcon name="i-lucide-trending-up" class="size-5 text-purple-600 dark:text-purple-400" />
                </div>
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Promedio/Semana</span>
              </div>
              <span class="text-xl font-bold text-purple-600 dark:text-purple-400 tabular-nums">
                {{ payrollStore.calculateEmployeeStats(employee).avgHoursPerWeek.toFixed(1) }}
              </span>
            </div>

            <!-- Pago Total - Destacado -->
            <div
              class="p-5 bg-gradient-to-br from-violet-50 to-purple-50 dark:from-violet-950/30 dark:to-purple-950/30 rounded-xl border-2 border-violet-200 dark:border-violet-800">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                  <div class="p-2 bg-violet-500/10 rounded-lg">
                    <UIcon name="i-lucide-wallet" class="size-6 text-violet-600 dark:text-violet-400" />
                  </div>
                  <span class="text-sm font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wide">Pago
                    Total</span>
                </div>
                <span class="text-2xl font-black text-violet-600 dark:text-violet-400 tabular-nums">
                  {{ payrollStore.formatCurrency(payrollStore.calculateEmployeeStats(employee).totalPay,
                    employee.settings.currency)
                  }}
                </span>
              </div>
            </div>
          </div>

          <!-- Action Buttons -->
          <div class="grid grid-cols-2 gap-3 mt-4">
            <UButton label="Ver Historial Detallado" icon="i-lucide-history" color="primary" variant="soft" block
              size="lg" @click="emit('view-employee', employee.id)" />
            <UButton label="Exportar" icon="i-lucide-download" color="success" variant="soft" block size="lg"
              @click="emit('export-employee', employee)" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
