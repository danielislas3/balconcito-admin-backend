<script setup lang="ts">
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'

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
</script>

<template>
  <div class="space-y-6">
    <!-- Selector de Empleado y Semana -->
    <PayrollMoleculesEmployeeWeekSelector
      @add-employee="emit('add-employee')"
      @delete-employee="emit('delete-employee')"
      @create-week="emit('create-week')"
      @save-week="emit('save-week')" />

    <!-- Tabla de Horarios -->
    <PayrollMoleculesScheduleTable
      v-if="currentEmployee && currentWeek"
      :week="currentWeek"
      :employee-name="currentEmployee.name" />

    <!-- Resumen Semanal -->
    <PayrollMoleculesWeeklySummaryCards
      v-if="currentWeek"
      :total-hours="weekTotals.totalHours"
      :total-shifts="weekTotals.totalShifts"
      :total-extra-hours="weekTotals.totalExtraHours"
      :total-pay="weekTotals.totalPay" />

    <!-- Propinas Semanales -->
    <UCard v-if="currentWeek"
      class="bg-gradient-to-br from-amber-50 to-yellow-50 dark:from-amber-950/50 dark:to-yellow-950/50 border-2 border-amber-200 dark:border-amber-800 shadow-lg">
      <template #header>
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-coins" class="size-5 text-amber-600" />
          <h3 class="text-lg font-semibold">Propinas de la Semana</h3>
        </div>
      </template>

      <div class="grid md:grid-cols-3 gap-6 items-center">
        <UFormField label="Total de Propinas">
          <UInput v-model.number="currentWeek.weeklyTips" type="number" step="0.01" min="0" placeholder="0.00"
            icon="i-lucide-dollar-sign" size="lg" @input="payrollStore.saveSystemData" />
        </UFormField>
        <div class="text-center">
          <div class="text-sm text-gray-500 mb-1">Pago Base</div>
          <div class="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {{ payrollStore.formatCurrency(weekTotals.totalBasePay) }}
          </div>
        </div>
        <div class="text-center">
          <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Total Final</div>
          <div
            class="text-3xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
            {{ payrollStore.formatCurrency(weekTotals.totalBasePay + (currentWeek.weeklyTips || 0)) }}
          </div>
        </div>
      </div>
    </UCard>

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
