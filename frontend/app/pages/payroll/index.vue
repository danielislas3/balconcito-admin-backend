<script setup lang="ts">
import type { PayrollEmployee } from '~/types/payroll'
import { usePayrollStore } from '~/stores/payroll'
import { storeToRefs } from 'pinia'

definePageMeta({
  layout: 'default',
  requiresAuth: false,
  ssr: false  // Deshabilitar SSR porque ahora carga datos del backend via API
})

const router = useRouter()
const payrollStore = usePayrollStore()
const toast = useToast()

// Store refs
const {
  employees,
  currentEmployee,
  currentWeek,
  activeTab,
  loading
} = storeToRefs(payrollStore)

// Modales
const showAddEmployeeModal = ref(false)
const newEmployeeName = ref('')
const newEmployeeRate = ref(450)
const newEmployeeCurrency = ref<'MXN' | 'USD' | 'EUR'>('MXN')
const employeeNameError = ref('')

// Refs para animaciones
const saveIndicatorVisible = ref(false)
const saveMessage = ref('Guardado automáticamente')

// Cargar datos al montar el componente
onMounted(async () => {
  await payrollStore.fetchEmployees()
})

// Funciones para empleados
const openAddEmployeeModal = () => {
  newEmployeeName.value = ''
  newEmployeeRate.value = 450
  newEmployeeCurrency.value = 'MXN'
  employeeNameError.value = ''
  showAddEmployeeModal.value = true
}

const closeAddEmployeeModal = () => {
  showAddEmployeeModal.value = false
  newEmployeeName.value = ''
  newEmployeeRate.value = 450
  newEmployeeCurrency.value = 'MXN'
  employeeNameError.value = ''
}

const handleAddEmployee = async () => {
  const result = await payrollStore.createEmployee(
    newEmployeeName.value,
    newEmployeeRate.value,
    newEmployeeCurrency.value
  )

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

const handleDeleteEmployee = async () => {
  if (!currentEmployee.value) return

  const name = currentEmployee.value.name
  if (!confirm(`¿Estás seguro de que quieres eliminar a ${name}?\n\nSe perderán todos sus horarios y no se puede deshacer.`)) {
    return
  }

  const result = await payrollStore.deleteCurrentEmployee()

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
const handleCreateWeek = async () => {
  // Calcular el siguiente lunes
  const today = new Date()
  const day = today.getDay()
  const diff = today.getDate() - day + (day === 0 ? -6 : 1)
  const monday = new Date(today.setDate(diff))
  const weekKey = monday.toISOString().split('T')[0]

  const result = await payrollStore.createWeek(weekKey, 0)

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

// Funciones de exportación
const handleExportAll = () => {
  payrollStore.exportAllEmployees()
  showSaveIndicator('Reporte general exportado')
}

const handleExportEmployee = (employee: PayrollEmployee) => {
  payrollStore.exportEmployeeData(employee)
  showSaveIndicator(`Datos de ${employee.name} exportados`)
}

const handleViewEmployee = (employeeId: string) => {
  router.push(`/payroll/employee/${employeeId}`)
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

      <!-- Loading Overlay -->
      <Transition
        enter-active-class="transition duration-200 ease-out"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div v-if="loading" class="fixed inset-0 z-50 bg-black/20 backdrop-blur-sm flex items-center justify-center">
          <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-8 flex flex-col items-center gap-4">
            <UIcon name="i-lucide-loader-2" class="size-12 text-emerald-600 animate-spin" />
            <p class="text-lg font-semibold text-gray-700 dark:text-gray-300">Cargando...</p>
          </div>
        </div>
      </Transition>

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
    <div class="mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="payroll-content">
        <!-- PESTAÑA DE HORARIOS -->
        <PayrollOrganismsSchedulesTab v-show="activeTab === 'schedules'" @add-employee="openAddEmployeeModal"
          @delete-employee="handleDeleteEmployee" @create-week="handleCreateWeek" />

        <!-- PESTAÑA MENSUAL -->
        <PayrollOrganismsMonthlyDashboard v-show="activeTab === 'monthly'" />

        <!-- PESTAÑA DE REPORTES -->
        <PayrollOrganismsReportsTab v-show="activeTab === 'reports'" @export-all="handleExportAll"
          @export-employee="handleExportEmployee" @view-employee="handleViewEmployee" />

        <!-- PESTAÑA DE CONFIGURACIÓN -->
        <PayrollOrganismsSettingsTab v-show="activeTab === 'settings'" />
      </div>
    </div>

    <!-- Modal Agregar Empleado -->
    <UModal v-model:open="showAddEmployeeModal" title="Agregar Nuevo Empleado"
      description="Ingresa los datos del nuevo empleado" :ui="{ content: 'w-full max-w-md' }">
      <template #body>
        <div class="space-y-4">
          <UFormField label="Nombre del Empleado" required :error="employeeNameError">
            <UInput v-model="newEmployeeName" placeholder="Ej. María García" @keyup.enter="handleAddEmployee" autofocus />
          </UFormField>

          <UFormField label="Tarifa por Hora" required>
            <UInput v-model.number="newEmployeeRate" type="number" placeholder="450" />
          </UFormField>

          <UFormField label="Moneda" required>
            <USelect v-model="newEmployeeCurrency" :options="[
              { value: 'MXN', label: 'Pesos Mexicanos (MXN)' },
              { value: 'USD', label: 'Dólares (USD)' },
              { value: 'EUR', label: 'Euros (EUR)' }
            ]" option-attribute="label" value-attribute="value" />
          </UFormField>
        </div>
      </template>

      <template #footer>
        <div class="flex justify-end gap-3">
          <UButton label="Cancelar" color="neutral" variant="ghost" @click="closeAddEmployeeModal" />
          <UButton label="Agregar" icon="i-lucide-check" color="success" @click="handleAddEmployee" :loading="loading" />
        </div>
      </template>
    </UModal>
    </div>
  </ClientOnly>
</template>
