<script setup lang="ts">
import type { Employee } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'

definePageMeta({
  layout: 'default',
  requiresAuth: false,
  ssr: false  // Deshabilitar SSR porque depende de datos del cliente (localStorage)
})

const router = useRouter()
const payrollStore = usePayrollStore()
const toast = useToast()

// Store refs
const {
  employees,
  currentEmployee,
  currentWeek,
  activeTab
} = storeToRefs(payrollStore)

// Modales
const showAddEmployeeModal = ref(false)
const showImportModal = ref(false)
const newEmployeeName = ref('')
const employeeNameError = ref('')
const importFile = ref<File | null>(null)

// Refs para animaciones
const saveIndicatorVisible = ref(false)
const saveMessage = ref('Guardado automáticamente')

// Los datos se cargan automáticamente mediante el plugin payroll-store.client.ts

// Funciones para empleados
const openAddEmployeeModal = () => {
  newEmployeeName.value = ''
  employeeNameError.value = ''
  showAddEmployeeModal.value = true
}

const closeAddEmployeeModal = () => {
  showAddEmployeeModal.value = false
  newEmployeeName.value = ''
  employeeNameError.value = ''
}

const handleAddEmployee = () => {
  const result = payrollStore.addNewEmployee(newEmployeeName.value)

  if (result.success) {
    toast.add({
      title: 'Éxito',
      description: 'Empleado agregado correctamente',
      color: 'success'
    })
    closeAddEmployeeModal()
    showSaveIndicator('Empleado agregado exitosamente')
  } else {
    employeeNameError.value = result.error || 'Error desconocido'
  }
}

const handleDeleteEmployee = () => {
  if (!currentEmployee.value) return

  const name = currentEmployee.value.name
  if (!confirm(`¿Estás seguro de que quieres eliminar a ${name}?\n\nSe perderán todos sus horarios y no se puede deshacer.`)) {
    return
  }

  const result = payrollStore.deleteCurrentEmployee()

  if (result.success) {
    toast.add({
      title: 'Éxito',
      description: 'Empleado eliminado correctamente',
      color: 'success'
    })
    showSaveIndicator('Empleado eliminado')
  } else {
    toast.add({
      title: 'Error',
      description: result.error || 'No se pudo eliminar el empleado',
      color: 'error'
    })
  }
}

// Funciones para semanas
const handleCreateWeek = () => {
  const result = payrollStore.createNewWeek()

  if (result.success) {
    toast.add({
      title: 'Éxito',
      description: 'Nueva semana creada',
      color: 'success'
    })
    showSaveIndicator('Nueva semana creada')
  } else {
    toast.add({
      title: 'Error',
      description: result.error || 'No se pudo crear la semana',
      color: 'error'
    })
  }
}

const handleSaveWeek = () => {
  payrollStore.saveCurrentWeek()
  toast.add({
    title: 'Éxito',
    description: 'Semana guardada correctamente',
    color: 'success'
  })
  showSaveIndicator('Semana guardada exitosamente')
}

// Funciones de exportación
const handleExportSystem = () => {
  payrollStore.exportSystemData()
  showSaveIndicator('Sistema exportado exitosamente')
}

const handleExportAll = () => {
  payrollStore.exportAllEmployees()
  showSaveIndicator('Reporte general exportado')
}

const handleExportEmployee = (employee: Employee) => {
  payrollStore.exportEmployeeData(employee)
  showSaveIndicator(`Datos de ${employee.name} exportados`)
}

const handleViewEmployee = (employeeId: string) => {
  router.push(`/payroll/employee/${employeeId}`)
}

// Funciones de importación
const openImportModal = () => {
  importFile.value = null
  showImportModal.value = true
}

const closeImportModal = () => {
  showImportModal.value = false
  importFile.value = null
  const fileInput = document.getElementById('file-upload') as HTMLInputElement
  if (fileInput) {
    fileInput.value = ''
  }
}

const handleFileSelect = (event: Event) => {
  const input = event.target as HTMLInputElement
  if (input.files && input.files[0]) {
    importFile.value = input.files[0]
  }
}

const handleImportData = async () => {
  if (!importFile.value) {
    toast.add({
      title: 'Error',
      description: 'Por favor selecciona un archivo',
      color: 'error'
    })
    return
  }

  const result = await payrollStore.importSystemData(importFile.value)

  if (result.success) {
    toast.add({
      title: 'Éxito',
      description: 'Datos importados correctamente',
      color: 'success'
    })
    closeImportModal()
    showSaveIndicator('Datos importados exitosamente')
  } else {
    toast.add({
      title: 'Error',
      description: result.error || 'Error al importar datos',
      color: 'error'
    })
  }
}

const handleClearAll = () => {
  if (!confirm('¿Estás seguro de que quieres limpiar TODOS los datos del sistema?\n\nEsta acción no se puede deshacer.')) {
    return
  }

  if (!confirm('Esta es tu última oportunidad. Se eliminarán todos los empleados y horarios.\n\n¿Continuar?')) {
    return
  }

  payrollStore.clearAllSystemData()
  toast.add({
    title: 'Sistema limpiado',
    description: 'Todos los datos han sido eliminados',
    color: 'success'
  })
  showSaveIndicator('Sistema limpiado completamente')
}

const showSaveIndicator = (message: string) => {
  saveMessage.value = message
  saveIndicatorVisible.value = true
  setTimeout(() => {
    saveIndicatorVisible.value = false
  }, 3000)
}

// Computed para tabs
const tabs = computed(() => [
  {
    id: 'schedules',
    label: 'Horarios',
    icon: 'i-lucide-calendar',
    badge: currentWeek.value ? undefined : '!'
  },
  {
    id: 'monthly',
    label: 'Mensual',
    icon: 'i-lucide-calendar-range',
    badge: undefined
  },
  {
    id: 'reports',
    label: 'Reportes',
    icon: 'i-lucide-bar-chart-3',
    badge: employees.value.length
  },
  {
    id: 'settings',
    label: 'Configuración',
    icon: 'i-lucide-settings'
  }
])
</script>

<template>
  <ClientOnly>
    <div
      class="min-h-screen w-full bg-gradient-to-br from-emerald-50 via-white to-teal-50 dark:from-gray-900 dark:via-gray-800 dark:to-emerald-950 overflow-y-auto">
      <!-- Indicador de guardado flotante -->
      <Transition enter-active-class="transition duration-300 ease-out" enter-from-class="translate-x-full opacity-0"
        enter-to-class="translate-x-0 opacity-100" leave-active-class="transition duration-200 ease-in"
        leave-from-class="translate-x-0 opacity-100" leave-to-class="translate-x-full opacity-0">
        <div v-if="saveIndicatorVisible"
          class="fixed top-20 right-6 z-50 flex items-center gap-3 px-5 py-3 bg-gradient-to-r from-emerald-600 to-teal-600 text-white rounded-xl shadow-xl shadow-emerald-900/20 backdrop-blur-sm">
          <UIcon name="i-lucide-check-circle-2" class="size-5 animate-pulse" />
          <span class="font-medium tracking-wide">{{ saveMessage }}</span>
        </div>
      </Transition>

    <!-- Header con gradiente premium -->
    <div
      class="bg-gradient-to-r from-emerald-600 via-emerald-700 to-teal-700 shadow-2xl shadow-emerald-900/30 sticky top-0 z-40 backdrop-blur-md bg-opacity-95">
      <div class="max-w-7xl mx-auto px-6 lg:px-8">
        <div class="flex items-center justify-between h-20">
          <div class="flex items-center gap-4">
            <div class="flex items-center justify-center w-12 h-12 bg-white/10 backdrop-blur-sm rounded-xl">
              <UIcon name="i-lucide-calculator" class="size-7 text-white" />
            </div>
            <div>
              <h1 class="text-3xl font-bold text-white tracking-tight">Sistema de Nóminas</h1>
              <p class="text-sm text-emerald-100/80 mt-0.5">Gestión de empleados y pagos</p>
            </div>
          </div>
          <div class="flex items-center gap-3">
            <UButton label="Nuevo Empleado" icon="i-lucide-user-plus" color="primary" variant="soft" size="lg"
              @click="openAddEmployeeModal"
              class="shadow-lg hover:shadow-xl transition-all duration-200 hover:scale-105" />
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs Navigation con diseño moderno -->
    <div
      class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md border-b border-emerald-200/50 dark:border-emerald-800/50 sticky top-20 z-30">
      <div class="max-w-7xl mx-auto px-6 lg:px-8">
        <div class="flex gap-2 py-3">
          <button v-for="tab in tabs" :key="tab.id" @click="activeTab = tab.id" :class="[
            'group relative px-6 py-3 rounded-xl text-sm font-semibold transition-all duration-200 flex items-center gap-2',
            activeTab === tab.id
              ? 'bg-gradient-to-br from-emerald-600 to-teal-600 text-white shadow-lg shadow-emerald-600/30 scale-105'
              : 'text-gray-600 dark:text-gray-300 hover:bg-emerald-50 dark:hover:bg-emerald-900/20 hover:text-emerald-700 dark:hover:text-emerald-300'
          ]">
            <UIcon :name="tab.icon" class="size-4" />
            <span class="font-semibold">{{ tab.label }}</span>
            <UBadge v-if="tab.badge" :color="activeTab === tab.id ? 'white' : 'success'" variant="solid" size="xs"
              class="ml-1">
              {{ tab.badge }}
            </UBadge>
            <!-- Indicador activo -->
            <div v-if="activeTab === tab.id"
              class="absolute -bottom-3 left-1/2 -translate-x-1/2 w-2 h-2 bg-emerald-600 rounded-full">
            </div>
          </button>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="payroll-content">
        <!-- PESTAÑA DE HORARIOS -->
        <PayrollOrganismsSchedulesTab v-show="activeTab === 'schedules'" @add-employee="openAddEmployeeModal"
          @delete-employee="handleDeleteEmployee" @create-week="handleCreateWeek" @save-week="handleSaveWeek" />

        <!-- PESTAÑA MENSUAL -->
        <PayrollOrganismsMonthlyDashboard v-show="activeTab === 'monthly'" />

        <!-- PESTAÑA DE REPORTES -->
        <PayrollOrganismsReportsTab v-show="activeTab === 'reports'" @export-all="handleExportAll"
          @export-employee="handleExportEmployee" @view-employee="handleViewEmployee" />

        <!-- PESTAÑA DE CONFIGURACIÓN -->
        <PayrollOrganismsSettingsTab v-show="activeTab === 'settings'" @export-system="handleExportSystem"
          @import-data="openImportModal" @clear-all="handleClearAll" />
      </div>
    </div>

    <!-- Modal Agregar Empleado -->
    <UModal v-model:open="showAddEmployeeModal" title="Agregar Nuevo Empleado"
      description="Ingresa el nombre del nuevo empleado" :ui="{ content: 'w-full max-w-md' }">
      <template #body>
        <UFormField label="Nombre del Empleado" required :error="employeeNameError">
          <UInput v-model="newEmployeeName" placeholder="Ej. María García" @keyup.enter="handleAddEmployee" autofocus />
        </UFormField>
      </template>

      <template #footer>
        <div class="flex justify-end gap-3">
          <UButton label="Cancelar" color="neutral" variant="ghost" @click="closeAddEmployeeModal" />
          <UButton label="Agregar" icon="i-lucide-check" color="success" @click="handleAddEmployee" />
        </div>
      </template>
    </UModal>

    <!-- Modal Importar Datos -->
    <UModal v-model:open="showImportModal" title="Importar Datos del Sistema"
      description="Selecciona un archivo JSON con los datos a importar" :ui="{ content: 'w-full max-w-md' }">
      <template #body>
        <div class="space-y-4">
          <UFormField label="Selecciona un archivo JSON" required>
            <div class="relative">
              <input type="file" accept=".json" @change="handleFileSelect" class="sr-only" id="file-upload" />
              <label for="file-upload" :class="[
                'flex flex-col items-center justify-center w-full px-6 py-8 border-2 border-dashed rounded-xl cursor-pointer transition-all duration-200',
                importFile
                  ? 'border-emerald-400 bg-emerald-50 dark:border-emerald-600 dark:bg-emerald-950/20'
                  : 'border-gray-300 bg-gray-50 dark:border-gray-600 dark:bg-gray-800 hover:border-emerald-400 hover:bg-emerald-50/50 dark:hover:border-emerald-600 dark:hover:bg-emerald-950/10'
              ]">
                <UIcon :name="importFile ? 'i-lucide-file-check' : 'i-lucide-file-json'"
                  :class="importFile ? 'size-12 text-emerald-600 dark:text-emerald-400 mb-3' : 'size-12 text-gray-400 dark:text-gray-500 mb-3'" />
                <span v-if="!importFile" class="text-sm font-medium text-gray-700 dark:text-gray-300 text-center">
                  Haz clic para seleccionar un archivo JSON
                </span>
                <div v-else class="text-center space-y-1">
                  <span class="block text-sm font-semibold text-emerald-700 dark:text-emerald-300">
                    {{ importFile.name }}
                  </span>
                  <span class="block text-xs text-emerald-600 dark:text-emerald-400">
                    {{ (importFile.size / 1024).toFixed(2) }} KB
                  </span>
                </div>
              </label>
            </div>
          </UFormField>

          <UAlert color="warning" variant="subtle" icon="i-lucide-alert-triangle" title="Advertencia"
            description="La importación reemplazará todos los datos actuales del sistema. Asegúrate de haber exportado tus datos antes de continuar." />
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-3">
          <UButton label="Cancelar" color="neutral" variant="ghost" @click="closeImportModal" />
          <UButton label="Importar" icon="i-lucide-upload" color="success" @click="handleImportData"
            :disabled="!importFile" />
        </div>
      </template>
    </UModal>
    </div>
  </ClientOnly>
</template>
