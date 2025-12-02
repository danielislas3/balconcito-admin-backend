<script setup lang="ts">
import type { Employee } from '~/stores/payroll'
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
  employees,
  currentEmployeeId,
  currentWeekId,
  currentEmployee,
  currentEmployeeWeeks
} = storeToRefs(payrollStore)

const employeeOptions = computed(() =>
  employees.value.map(emp => ({
    label: emp.name,
    value: emp.id
  }))
)

const weekOptions = computed(() =>
  currentEmployeeWeeks.value.map(week => ({
    label: `Semana del ${payrollStore.formatWeekDisplay(week.startDate)}`,
    value: week.id
  }))
)

const currencyOptions = [
  { label: 'Pesos Mexicanos (MXN)', value: 'MXN', icon: 'i-lucide-dollar-sign' },
  { label: 'Dólares (USD)', value: 'USD', icon: 'i-lucide-dollar-sign' },
  { label: 'Euros (EUR)', value: 'EUR', icon: 'i-lucide-euro' }
]
</script>

<template>
  <UCard
    class="bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-emerald-100 dark:border-emerald-900">
    <template #header>
      <div class="flex items-center gap-2">
        <UIcon name="i-lucide-users" class="size-5 text-success-600" />
        <h2 class="text-lg font-semibold">Gestión de Empleados y Semanas</h2>
      </div>
    </template>

    <div class="grid md:grid-cols-4 gap-4">
      <!-- Empleado Activo -->
      <UFormField label="Empleado Activo" required>
        <div class="flex gap-2">
          <select
            v-model="currentEmployeeId"
            @change="payrollStore.onEmployeeChange"
            class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-emerald-500 focus:border-transparent shadow-sm"
          >
            <option value="" disabled>Seleccionar empleado...</option>
            <option v-for="emp in employees" :key="emp.id" :value="emp.id">
              {{ emp.name }}
            </option>
          </select>
          <UButton icon="i-lucide-plus" color="success" @click="emit('add-employee')" square />
        </div>
      </UFormField>

      <!-- Semana Activa -->
      <UFormField label="Semana Activa">
        <div class="flex gap-2">
          <select
            v-model="currentWeekId"
            @change="payrollStore.onWeekChange"
            :disabled="!currentEmployee"
            class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-emerald-500 focus:border-transparent shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <option value="" disabled>Seleccionar semana...</option>
            <option v-for="week in currentEmployeeWeeks" :key="week.id" :value="week.id">
              Semana del {{ payrollStore.formatWeekDisplay(week.startDate) }}
            </option>
          </select>
          <UButton icon="i-lucide-calendar-plus" color="success" @click="emit('create-week')"
            :disabled="!currentEmployee" square />
        </div>
      </UFormField>

      <!-- Costo por Turno -->
      <UFormField label="Costo por Turno">
        <UInput v-if="currentEmployee" v-model.number="currentEmployee.settings.costPerTurn" type="number" step="0.01"
          @input="payrollStore.onSettingsChange" icon="i-lucide-dollar-sign" />
        <UInput v-else disabled type="number" placeholder="0.00" icon="i-lucide-dollar-sign" />
      </UFormField>

      <!-- Moneda -->
      <UFormField label="Moneda">
        <select
          v-if="currentEmployee"
          v-model="currentEmployee.settings.currency"
          @change="payrollStore.onSettingsChange"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:ring-2 focus:ring-emerald-500 focus:border-transparent shadow-sm"
        >
          <option v-for="option in currencyOptions" :key="option.value" :value="option.value">
            {{ option.label }}
          </option>
        </select>
        <select
          v-else
          disabled
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 shadow-sm opacity-50 cursor-not-allowed"
        >
          <option>MXN</option>
        </select>
      </UFormField>
    </div>

    <template #footer>
      <div class="flex gap-3">
        <UButton label="Eliminar Empleado" icon="i-lucide-trash-2" color="error" variant="outline"
          @click="emit('delete-employee')" :disabled="!currentEmployee || employees.length <= 1" />
        <UButton label="Guardar Semana" icon="i-lucide-save" color="success" @click="emit('save-week')"
          :disabled="!currentEmployee" />
      </div>
    </template>
  </UCard>
</template>
