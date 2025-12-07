<script setup lang="ts">
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'
import { formatCurrency } from '~/utils/payrollFormatters'

const emit = defineEmits<{
  'add-employee': []
  'delete-employee': []
  'create-week': []
  'save-week': []
}>()

const payrollStore = usePayrollStore()
const {
  currentEmployee,
  currentWeek,
  weekTotals
} = storeToRefs(payrollStore)

// Helper to format currency using employee's settings
const formatEmployeeCurrency = (amount: number) => {
  const currency = currentEmployee.value?.settings.currency || 'MXN'
  return formatCurrency(amount, currency as any)
}
</script>

<template>
  <div class="space-y-6">
    <!-- Selector de Empleado y Semana -->
    <PayrollMoleculesEmployeeWeekSelector
      @add-employee="emit('add-employee')"
      @delete-employee="emit('delete-employee')"
      @create-week="emit('create-week')"
      @save-week="emit('save-week')" />

    <!-- Layout de 2 columnas en pantallas grandes -->
    <div v-if="currentEmployee && currentWeek" class="grid grid-cols-1 lg:grid-cols-5 gap-4">
      <!-- Columna Izquierda: Tabla de Horarios (60%) -->
      <div class="lg:col-span-3">
        <PayrollMoleculesScheduleTable
          :week="currentWeek"
          :employee-name="currentEmployee.name" />
      </div>

      <!-- Columna Derecha: Widgets de Resumen (40%) -->
      <div class="lg:col-span-2 space-y-4">
        <!-- Resumen Semanal -->
        <PayrollMoleculesWeeklySummaryCards
          :total-hours="weekTotals.totalHours"
          :total-shifts="weekTotals.totalShifts"
          :total-extra-hours="weekTotals.totalExtraHours"
          :total-pay="weekTotals.totalPay" />

        <!-- Resumen Compacto para Screenshot -->
        <PayrollMoleculesWeekSummaryCompact
          :week="currentWeek"
          :employee-name="currentEmployee.name"
          :currency="currentEmployee.settings?.currency" />

        <!-- Propinas Semanales -->
        <UCard
          class="bg-gradient-to-br from-amber-50 to-yellow-50 dark:from-amber-950/50 dark:to-yellow-950/50 border-2 border-amber-200 dark:border-amber-800 shadow-lg">
          <template #header>
            <div class="flex items-center gap-2">
              <UIcon name="i-lucide-coins" class="size-5 text-amber-600" />
              <h3 class="text-base font-semibold">Propinas</h3>
            </div>
          </template>

          <div class="space-y-3">
            <UFormField label="Total de Propinas">
              <UInput v-model.number="currentWeek.weeklyTips" type="number" step="0.01" min="0" placeholder="0.00"
                icon="i-lucide-dollar-sign" size="md" @input="payrollStore.saveSystemData" />
            </UFormField>
            <div class="flex justify-between items-center p-2 bg-white/50 dark:bg-gray-800/50 rounded">
              <span class="text-sm text-gray-600 dark:text-gray-400">Pago Base</span>
              <span class="text-lg font-bold text-gray-900 dark:text-gray-100">
                {{ formatEmployeeCurrency(weekTotals.totalBasePay) }}
              </span>
            </div>
            <div class="flex justify-between items-center p-3 bg-white/80 dark:bg-gray-800/80 rounded-lg border-2 border-amber-300 dark:border-amber-700">
              <span class="text-sm font-semibold text-gray-700 dark:text-gray-300">Total Final</span>
              <span class="text-2xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
                {{ formatEmployeeCurrency(weekTotals.totalBasePay + (currentWeek.weeklyTips || 0)) }}
              </span>
            </div>
          </div>
        </UCard>
      </div>
    </div>

    <!-- Estados vacíos -->
    <UCard v-if="!currentEmployee"
      class="bg-white dark:bg-gray-800 border-2 border-dashed border-gray-300 dark:border-gray-700">
      <div class="py-12 text-center space-y-4">
        <div class="flex justify-center">
          <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-full">
            <UIcon name="i-lucide-users" class="size-16 text-gray-400 dark:text-gray-500" />
          </div>
        </div>
        <h3 class="text-xl font-bold text-gray-900 dark:text-white">No hay empleado seleccionado</h3>
        <p class="text-gray-600 dark:text-gray-400 max-w-md mx-auto">Selecciona un empleado existente o crea uno
          nuevo para comenzar.</p>
        <UButton label="Agregar Primer Empleado" icon="i-lucide-user-plus" color="success" size="lg"
          @click="emit('add-employee')" class="mt-4" />
      </div>
    </UCard>

    <UCard v-else-if="!currentWeek"
      class="bg-white dark:bg-gray-800 border-2 border-dashed border-gray-300 dark:border-gray-700">
      <div class="py-12 text-center space-y-4">
        <div class="flex justify-center">
          <div class="p-6 bg-gray-100 dark:bg-gray-700 rounded-full">
            <UIcon name="i-lucide-calendar" class="size-16 text-gray-400 dark:text-gray-500" />
          </div>
        </div>
        <h3 class="text-xl font-bold text-gray-900 dark:text-white">No hay semana seleccionada</h3>
        <p class="text-gray-600 dark:text-gray-400 max-w-md mx-auto">Selecciona una semana existente o crea una nueva
          para {{ currentEmployee.name }}.</p>
        <UButton label="Crear Nueva Semana" icon="i-lucide-calendar-plus" color="success" size="lg"
          @click="emit('create-week')" class="mt-4" />
      </div>
    </UCard>
  </div>
</template>
