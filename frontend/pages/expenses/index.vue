<template>
  <div>
    <div class="mb-8 flex justify-between items-center">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">Gastos</h1>
        <p class="text-gray-600 mt-2">Registro de gastos del negocio</p>
      </div>
      <UButton 
        to="/expenses/new"
        icon="i-heroicons-plus"
        size="lg"
      >
        Nuevo Gasto
      </UButton>
    </div>

    <!-- Filtros -->
    <div class="mb-6 bg-white p-4 rounded-lg shadow grid md:grid-cols-5 gap-4">
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
        v-model="filters.category"
        :options="categoryOptions"
        placeholder="Categoría"
      />
      <USelect 
        v-model="filters.paymentSource"
        :options="paymentSourceOptions"
        placeholder="Fuente de pago"
      />
      <div class="flex gap-2">
        <UButton @click="loadExpenses" class="flex-1">Filtrar</UButton>
        <UButton color="white" @click="clearFilters">Limpiar</UButton>
      </div>
    </div>

    <!-- Alerta de reembolsos pendientes -->
    <UAlert
      v-if="filters.requiresReimbursement === 'true'"
      color="amber"
      icon="i-heroicons-exclamation-triangle"
      title="Mostrando solo gastos pendientes de reembolso"
      class="mb-6"
    />

    <!-- Lista de gastos -->
    <UCard>
      <div v-if="loading" class="space-y-4">
        <USkeleton class="h-16" v-for="i in 5" :key="i" />
      </div>

      <div v-else-if="expenses.length === 0" class="text-center py-12">
        <p class="text-gray-500">No hay gastos registrados</p>
      </div>

      <div v-else>
        <UTable :rows="expenses" :columns="columns">
          <template #expense_date-data="{ row }">
            {{ formatDate(row.expense_date) }}
          </template>

          <template #amount-data="{ row }">
            <span class="font-semibold text-red-600">
              ${{ formatCurrency(row.amount) }}
            </span>
          </template>

          <template #category-data="{ row }">
            <UBadge :color="getCategoryColor(row.cost_type)">
              {{ getCategoryLabel(row.category) }}
            </UBadge>
          </template>

          <template #payment_source-data="{ row }">
            <span class="text-sm">{{ getPaymentSourceLabel(row.payment_source) }}</span>
          </template>

          <template #requires_reimbursement-data="{ row }">
            <UBadge v-if="row.requires_reimbursement && !row.reimbursed" color="amber">
              Pendiente
            </UBadge>
            <UBadge v-else-if="row.requires_reimbursement && row.reimbursed" color="green">
              Reembolsado
            </UBadge>
            <span v-else class="text-gray-400">-</span>
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
          <div class="grid grid-cols-2 gap-4">
            <div>
              <p class="text-sm text-gray-600">Total Gastos</p>
              <p class="text-xl font-bold text-red-600">${{ formatCurrency(summary?.total_expenses || 0) }}</p>
            </div>
            <div>
              <p class="text-sm text-gray-600">Cantidad</p>
              <p class="text-xl font-bold">{{ summary?.count || 0 }}</p>
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
const expenses = ref([])
const summary = ref<any>(null)

const filters = reactive({
  dateFrom: '',
  dateTo: '',
  category: '',
  paymentSource: '',
  requiresReimbursement: ''
})

const categoryOptions = [
  { label: 'Todas', value: '' },
  { label: 'Cerveza', value: 'cerveza' },
  { label: 'Cerveza de Barril', value: 'cerveza_barril' },
  { label: 'Vinos y Licores', value: 'vinos_licores' },
  { label: 'Refrescos y Jugos', value: 'refrescos_jugos' },
  { label: 'Alimentos', value: 'alimentos' },
  { label: 'Desechables', value: 'desechables' },
  { label: 'Hielo', value: 'hielo' },
  { label: 'Insumos Secos', value: 'insumos_secos' },
  { label: 'Renta', value: 'renta' },
  { label: 'Nómina', value: 'nomina' },
  { label: 'Servicios', value: 'servicios' },
  { label: 'Gastos Financieros', value: 'gastos_financieros' },
  { label: 'Pago de Deuda', value: 'pago_deuda' },
  { label: 'Mantenimiento', value: 'mantenimiento' },
  { label: 'Gastos Staff', value: 'gastos_staff' },
  { label: 'Gastos Varios', value: 'gastos_varios' }
]

const paymentSourceOptions = [
  { label: 'Todas', value: '' },
  { label: 'Efectivo (Caja Chica)', value: 'efectivo_caja_chica' },
  { label: 'Efectivo (Bóveda)', value: 'efectivo_boveda' },
  { label: 'Transferencia (Mercado Pago)', value: 'transferencia_negocio' },
  { label: 'Tarjeta del Negocio', value: 'tarjeta_negocio' },
  { label: 'Tarjeta de Daniel', value: 'tarjeta_daniel' },
  { label: 'Tarjeta de Raúl', value: 'tarjeta_raul' }
]

const columns = [
  { key: 'expense_date', label: 'Fecha' },
  { key: 'description', label: 'Descripción' },
  { key: 'amount', label: 'Monto' },
  { key: 'category', label: 'Categoría' },
  { key: 'payment_source', label: 'Fuente de Pago' },
  { key: 'requires_reimbursement', label: 'Reembolso' },
  { key: 'actions', label: '' }
]

const loadExpenses = async () => {
  loading.value = true
  try {
    const params = new URLSearchParams()
    if (filters.dateFrom) params.append('date_from', filters.dateFrom)
    if (filters.dateTo) params.append('date_to', filters.dateTo)
    if (filters.category) params.append('category', filters.category)
    if (filters.paymentSource) params.append('payment_source', filters.paymentSource)
    if (filters.requiresReimbursement) params.append('requires_reimbursement', filters.requiresReimbursement)

    const data: any = await api.get(`/expenses?${params.toString()}`)
    expenses.value = data.expenses
    summary.value = data.summary
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar los gastos',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

const clearFilters = () => {
  filters.dateFrom = ''
  filters.dateTo = ''
  filters.category = ''
  filters.paymentSource = ''
  filters.requiresReimbursement = ''
  loadExpenses()
}

const deleteExpense = async (id: number) => {
  if (!confirm('¿Estás seguro de eliminar este gasto?')) return

  try {
    await api.delete(`/expenses/${id}`)
    toast.add({
      title: 'Éxito',
      description: 'Gasto eliminado correctamente',
      color: 'green'
    })
    loadExpenses()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudo eliminar el gasto',
      color: 'red'
    })
  }
}

const getActions = (row: any) => [[
  {
    label: 'Ver detalles',
    icon: 'i-heroicons-eye',
    click: () => navigateTo(`/expenses/${row.id}`)
  },
  {
    label: 'Eliminar',
    icon: 'i-heroicons-trash',
    click: () => deleteExpense(row.id)
  }
]]

const getCategoryColor = (costType: string) => {
  const colors: Record<string, string> = {
    cogs: 'red',
    fixed: 'blue',
    variable: 'amber'
  }
  return colors[costType] || 'gray'
}

const getCategoryLabel = (category: string) => {
  const option = categoryOptions.find(opt => opt.value === category)
  return option?.label || category
}

const getPaymentSourceLabel = (source: string) => {
  const option = paymentSourceOptions.find(opt => opt.value === source)
  return option?.label || source
}

onMounted(() => {
  loadExpenses()
})

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'short',
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
