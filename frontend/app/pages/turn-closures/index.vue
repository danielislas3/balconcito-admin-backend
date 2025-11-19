<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()
const api = useApi()
const toast = useToast()

const loading = ref(true)
const closures = ref<any[]>([])
const summary = ref<any>(null)

const filters = reactive({
  dateFrom: '',
  dateTo: '',
  closedBy: ''
})

const closedByOptions = [
  { label: 'Todos', value: '' },
  { label: 'David', value: 'David' },
  { label: 'Daniel', value: 'Daniel' },
  { label: 'Raúl', value: 'Raúl' },
  { label: 'Yahir', value: 'Yahir' }
]

const columns = [{
  key: 'closure_number',
  label: '#',
  sortable: true
}, {
  key: 'report_date',
  label: 'Fecha',
  sortable: true
}, {
  key: 'total_income',
  label: 'Total',
  sortable: true
}, {
  key: 'cash_collected',
  label: 'Efectivo'
}, {
  key: 'transfer_income',
  label: 'Transferencias'
}, {
  key: 'card_income',
  label: 'Tarjetas'
}, {
  key: 'closed_by',
  label: 'Cerrado por'
}, {
  key: 'actions',
  label: ''
}]

const loadClosures = async () => {
  loading.value = true
  try {
    const params = new URLSearchParams()
    if (filters.dateFrom) params.append('date_from', filters.dateFrom)
    if (filters.dateTo) params.append('date_to', filters.dateTo)
    if (filters.closedBy) params.append('closed_by', filters.closedBy)

    const data: any = await api.get(`/turn_closures?${params.toString()}`)
    closures.value = data.turn_closures || []
    summary.value = data.summary
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar los cierres',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

const clearFilters = () => {
  filters.dateFrom = ''
  filters.dateTo = ''
  filters.closedBy = ''
  loadClosures()
}

const deleteClosure = async (id: number) => {
  if (!confirm('¿Estás seguro de eliminar este cierre?')) return

  try {
    await api.delete(`/turn_closures/${id}`)
    toast.add({
      title: 'Éxito',
      description: 'Cierre eliminado correctamente',
      color: 'green'
    })
    loadClosures()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudo eliminar el cierre',
      color: 'red'
    })
  }
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

onMounted(() => {
  loadClosures()
})
</script>

<template>
  <UDashboardPanel id="turn-closures">
    <template #header>
      <UDashboardNavbar title="Cierres de Turno">
        <template #leading>
          <UDashboardSidebarCollapse />
        </template>

        <template #right>
          <UTooltip text="Notificaciones" :shortcuts="['N']">
            <UButton
              color="neutral"
              variant="ghost"
              square
              @click="isNotificationsSlideoverOpen = true"
            >
              <UIcon name="i-lucide-bell" class="size-5" />
            </UButton>
          </UTooltip>

          <UButton
            label="Nuevo Cierre"
            icon="i-lucide-plus"
            to="/turn-closures/new"
          />
        </template>
      </UDashboardNavbar>

      <UDashboardToolbar>
        <template #left>
          <UInput
            v-model="filters.dateFrom"
            type="date"
            placeholder="Desde"
            class="w-40"
          />
          <UInput
            v-model="filters.dateTo"
            type="date"
            placeholder="Hasta"
            class="w-40"
          />
          <USelect
            v-model="filters.closedBy"
            :options="closedByOptions"
            placeholder="Cerrado por"
            class="w-40"
          />
          <UButton @click="loadClosures" icon="i-lucide-filter">Filtrar</UButton>
          <UButton color="neutral" variant="ghost" @click="clearFilters">Limpiar</UButton>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <div class="space-y-6">
        <!-- Resumen -->
        <div v-if="summary" class="grid gap-4 sm:grid-cols-4">
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Total Cierres</p>
              <p class="text-3xl font-bold mt-1">{{ summary.total_closures || 0 }}</p>
            </div>
          </UCard>
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Ingresos Totales</p>
              <p class="text-3xl font-bold text-green-600 mt-1">${{ formatCurrency(summary.total_income || 0) }}</p>
            </div>
          </UCard>
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Efectivo</p>
              <p class="text-3xl font-bold mt-1">${{ formatCurrency(summary.total_cash || 0) }}</p>
            </div>
          </UCard>
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Digital</p>
              <p class="text-3xl font-bold mt-1">${{ formatCurrency((summary.total_transfers || 0) + (summary.total_cards || 0)) }}</p>
            </div>
          </UCard>
        </div>

        <!-- Tabla -->
        <UCard>
          <template #header>
            <h3 class="text-lg font-semibold">Lista de Cierres</h3>
          </template>

          <UTable
            v-if="!loading && closures.length > 0"
            :rows="closures"
            :columns="columns"
          >
            <template #closure_number-data="{ row }">
              <span class="font-mono font-semibold">#{{ row.closure_number }}</span>
            </template>

            <template #report_date-data="{ row }">
              {{ formatDate(row.report_date) }}
            </template>

            <template #total_income-data="{ row }">
              <span class="font-semibold text-green-600">${{ formatCurrency(row.total_income) }}</span>
            </template>

            <template #cash_collected-data="{ row }">
              ${{ formatCurrency(row.cash_collected) }}
            </template>

            <template #transfer_income-data="{ row }">
              ${{ formatCurrency(row.transfer_income) }}
            </template>

            <template #card_income-data="{ row }">
              ${{ formatCurrency(row.card_income) }}
            </template>

            <template #closed_by-data="{ row }">
              <UBadge color="blue" variant="subtle">{{ row.closed_by }}</UBadge>
            </template>

            <template #actions-data="{ row }">
              <UDropdownMenu
                :items="[[
                  { label: 'Ver detalles', icon: 'i-lucide-eye', to: `/turn-closures/${row.id}` },
                  { label: 'Eliminar', icon: 'i-lucide-trash', click: () => deleteClosure(row.id) }
                ]]"
              >
                <UButton color="neutral" variant="ghost" icon="i-lucide-more-vertical" size="xs" />
              </UDropdownMenu>
            </template>
          </UTable>

          <div v-else-if="loading" class="space-y-4 p-4">
            <USkeleton class="h-12" v-for="i in 5" :key="i" />
          </div>

          <div v-else class="text-center py-12">
            <UIcon name="i-lucide-inbox" class="size-12 text-gray-400 mx-auto mb-4" />
            <p class="text-gray-500">No hay cierres de turno registrados</p>
            <UButton to="/turn-closures/new" class="mt-4">Registrar primer cierre</UButton>
          </div>
        </UCard>
      </div>
    </template>
  </UDashboardPanel>
</template>
