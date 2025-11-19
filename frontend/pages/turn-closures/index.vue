<template>
  <div>
    <div class="mb-8 flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">Cierres de Turno</h1>
        <p class="text-gray-600 mt-2">Registro de cierres de caja diarios</p>
      </div>
      <UButton 
        to="/turn-closures/new"
        icon="i-heroicons-plus"
        size="lg"
      >
        Nuevo Cierre
      </UButton>
    </div>

    <!-- Filtros -->
    <div class="mb-6 bg-white p-4 rounded-lg shadow flex gap-4">
      <UInput 
        v-model="filters.dateFrom"
        type="date"
        label="Desde"
      />
      <UInput 
        v-model="filters.dateTo"
        type="date"
        label="Hasta"
      />
      <USelect 
        v-model="filters.closedBy"
        :options="closedByOptions"
        placeholder="Cerrado por"
      />
      <UButton @click="loadClosures">Filtrar</UButton>
      <UButton color="white" @click="clearFilters">Limpiar</UButton>
    </div>

    <!-- Lista de cierres -->
    <UCard>
      <div v-if="loading" class="space-y-4">
        <USkeleton class="h-16" v-for="i in 5" :key="i" />
      </div>

      <div v-else-if="closures.length === 0" class="text-center py-12">
        <p class="text-gray-500">No hay cierres de turno registrados</p>
      </div>

      <div v-else>
        <UTable :rows="closures" :columns="columns">
          <template #closure_number-data="{ row }">
            <span class="font-mono font-semibold">#{{ row.closure_number }}</span>
          </template>

          <template #report_date-data="{ row }">
            {{ formatDate(row.report_date) }}
          </template>

          <template #total_income-data="{ row }">
            <span class="font-semibold text-green-600">
              ${{ formatCurrency(row.total_income) }}
            </span>
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
            <UBadge color="blue">{{ row.closed_by }}</UBadge>
          </template>

          <template #actions-data="{ row }">
            <UDropdown :items="getActions(row)">
              <UButton 
                color="gray" 
                variant="ghost" 
                icon="i-heroicons-ellipsis-horizontal"
              />
            </UDropdown>
          </template>
        </UTable>

        <!-- Resumen -->
        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <h3 class="font-semibold mb-2">Resumen del período</h3>
          <div class="grid grid-cols-4 gap-4">
            <div>
              <p class="text-sm text-gray-600">Total Cierres</p>
              <p class="text-xl font-bold">{{ summary?.total_closures || 0 }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">Ingresos Totales</p>
              <p class="text-xl font-bold text-green-600">${{ formatCurrency(summary?.total_income || 0) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">Efectivo</p>
              <p class="text-xl font-bold">${{ formatCurrency(summary?.total_cash || 0) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">Digital</p>
              <p class="text-xl font-bold">${{ formatCurrency((summary?.total_transfers || 0) + (summary?.total_cards || 0)) }}</p>
            </div>
          </div>
        </div>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const api = useApi()
const toast = useToast()

const loading = ref(true)
const closures = ref([])
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
  { label: 'Raúl', value: 'Raúl' }
]

const columns = [
  { key: 'closure_number', label: '#' },
  { key: 'report_date', label: 'Fecha' },
  { key: 'total_income', label: 'Total' },
  { key: 'cash_collected', label: 'Efectivo' },
  { key: 'transfer_income', label: 'Transferencias' },
  { key: 'card_income', label: 'Tarjetas' },
  { key: 'closed_by', label: 'Cerrado por' },
  { key: 'actions', label: '' }
]

const loadClosures = async () => {
  loading.value = true
  try {
    const params = new URLSearchParams()
    if (filters.dateFrom) params.append('date_from', filters.dateFrom)
    if (filters.dateTo) params.append('date_to', filters.dateTo)
    if (filters.closedBy) params.append('closed_by', filters.closedBy)

    const data: any = await api.get(`/turn_closures?${params.toString()}`)
    closures.value = data.turn_closures
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

const getActions = (row: any) => [[
  {
    label: 'Ver detalles',
    icon: 'i-heroicons-eye',
    click: () => navigateTo(`/turn-closures/${row.id}`)
  },
  {
    label: 'Editar',
    icon: 'i-heroicons-pencil',
    click: () => navigateTo(`/turn-closures/${row.id}/edit`)
  },
  {
    label: 'Eliminar',
    icon: 'i-heroicons-trash',
    click: () => deleteClosure(row.id)
  }
]]

onMounted(() => {
  loadClosures()
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}
</script>
