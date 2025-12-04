<script setup lang="ts">
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'

const emit = defineEmits<{
  'export-system': []
  'import-data': []
  'clear-all': []
}>()

const payrollStore = usePayrollStore()
const { employees, totalWeeks } = storeToRefs(payrollStore)
</script>

<template>
  <div class="space-y-6">
    <UCard>
      <template #header>
        <div class="flex items-center gap-2">
          <UIcon name="i-lucide-settings" class="size-5 text-success-600" />
          <h2 class="text-lg font-semibold">Configuración del Sistema</h2>
        </div>
      </template>

      <div class="space-y-6">
        <!-- Gestión de Datos -->
        <div
          class="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950/30 dark:to-indigo-950/30 p-6 rounded-2xl border-2 border-blue-200 dark:border-blue-800">
          <div class="flex items-center gap-3 mb-6">
            <div class="p-2 bg-blue-500/10 rounded-lg">
              <UIcon name="i-lucide-database" class="size-6 text-blue-600 dark:text-blue-400" />
            </div>
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Gestión de Datos</h3>
          </div>
          <div class="flex flex-wrap gap-3">
            <UButton label="Exportar Sistema Completo" icon="i-lucide-download" color="primary" size="lg"
              @click="emit('export-system')" />
            <UButton label="Importar Datos" icon="i-lucide-upload" color="success" size="lg"
              @click="emit('import-data')" />
            <UButton label="Limpiar Todo" icon="i-lucide-trash-2" color="error" variant="outline" size="lg"
              @click="emit('clear-all')" />
          </div>
        </div>

        <!-- Estado del Sistema -->
        <div
          class="bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-950/30 dark:to-teal-950/30 p-6 rounded-2xl border-2 border-emerald-200 dark:border-emerald-800">
          <div class="flex items-center gap-3 mb-6">
            <div class="p-2 bg-emerald-500/10 rounded-lg">
              <UIcon name="i-lucide-info" class="size-6 text-emerald-600 dark:text-emerald-400" />
            </div>
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Estado del Sistema</h3>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex items-center justify-between p-4 bg-white/60 dark:bg-gray-800/60 rounded-xl">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Auto-guardado</span>
              <UBadge color="success" variant="subtle" size="md">Activo</UBadge>
            </div>
            <div class="flex items-center justify-between p-4 bg-white/60 dark:bg-gray-800/60 rounded-xl">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Versión</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">Vue 3 Multi-Empleado</span>
            </div>
            <div class="flex items-center justify-between p-4 bg-white/60 dark:bg-gray-800/60 rounded-xl">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Almacenamiento</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">localStorage del navegador</span>
            </div>
            <div class="flex items-center justify-between p-4 bg-white/60 dark:bg-gray-800/60 rounded-xl">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Empleados registrados</span>
              <UBadge color="primary" variant="subtle" size="md">{{ employees.length }}</UBadge>
            </div>
            <div class="flex items-center justify-between p-4 bg-white/60 dark:bg-gray-800/60 rounded-xl">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Total de semanas</span>
              <UBadge color="primary" variant="subtle" size="md">{{ totalWeeks }}</UBadge>
            </div>
          </div>
        </div>

        <!-- Información Importante -->
        <div
          class="bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/30 p-6 rounded-2xl border-2 border-amber-200 dark:border-amber-800">
          <div class="flex items-center gap-3 mb-6">
            <div class="p-2 bg-amber-500/10 rounded-lg">
              <UIcon name="i-lucide-alert-triangle" class="size-6 text-amber-600 dark:text-amber-400" />
            </div>
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Información Importante</h3>
          </div>
          <ul class="space-y-3">
            <li class="flex items-start gap-3">
              <div class="mt-0.5 p-1 bg-amber-500/10 rounded">
                <UIcon name="i-lucide-check-circle" class="size-4 text-amber-600 dark:text-amber-400" />
              </div>
              <span class="text-sm text-gray-700 dark:text-gray-300">Los datos se guardan automáticamente en el
                navegador</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="mt-0.5 p-1 bg-amber-500/10 rounded">
                <UIcon name="i-lucide-check-circle" class="size-4 text-amber-600 dark:text-amber-400" />
              </div>
              <span class="text-sm text-gray-700 dark:text-gray-300">Exporta regularmente para crear respaldos</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="mt-0.5 p-1 bg-amber-500/10 rounded">
                <UIcon name="i-lucide-alert-circle" class="size-4 text-amber-600 dark:text-amber-400" />
              </div>
              <span class="text-sm text-gray-700 dark:text-gray-300">Al limpiar el navegador se perderán todos los
                datos</span>
            </li>
            <li class="flex items-start gap-3">
              <div class="mt-0.5 p-1 bg-amber-500/10 rounded">
                <UIcon name="i-lucide-alert-circle" class="size-4 text-amber-600 dark:text-amber-400" />
              </div>
              <span class="text-sm text-gray-700 dark:text-gray-300">La importación reemplazará todos los datos
                actuales</span>
            </li>
          </ul>
        </div>
      </div>
    </UCard>
  </div>
</template>
