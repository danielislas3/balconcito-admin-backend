<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()
const api = useApi()
const toast = useToast()

const loading = ref(true)
const expenses = ref<any[]>([])
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
  { label: 'Mantenimiento', value: 'mantenimiento' },
  { label: 'Gastos Varios', value: 'gastos_varios' }
]

const paymentSourceOptions = [
  { label: 'Todas', value: '' },
  { label: 'Efectivo (Caja Chica)', value: 'efectivo_caja_chica' },
  { label: 'Efectivo (Bóveda)', value: 'efectivo_boveda' },
  { label: 'Transferencia (Negocio)', value: 'transferencia_negocio' },
  { label: 'Tarjeta del Negocio', value: 'tarjeta_negocio' },
  { label: 'Tarjeta de Daniel', value: 'tarjeta_daniel' },
  { label: 'Tarjeta de Raúl', value: 'tarjeta_raul' }
]

const columns = [{
  key: 'expense_date',
  label: 'Fecha',
  sortable: true
}, {
  key: 'description',
  label: 'Descripción'
}, {
  key: 'amount',
  label: 'Monto',
  sortable: true
}, {
  key: 'category',
  label: 'Categoría'
}, {
  key: 'payment_source',
  label: 'Fuente de Pago'
}, {
  key: 'requires_reimbursement',
  label: 'Reembolso'
}, {
  key: 'actions',
  label: ''
}]

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
    expenses.value = data.expenses || []
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

const getCategoryLabel = (category: string) => {
  const option = categoryOptions.find(opt => opt.value === category)
  return option?.label || category
}

const getPaymentSourceLabel = (source: string) => {
  const option = paymentSourceOptions.find(opt => opt.value === source)
  return option?.label || source
}

const getCategoryColor = (costType: string) => {
  const colors: Record<string, string> = {
    cogs: 'red',
    fixed: 'blue',
    variable: 'amber'
  }
  return colors[costType] || 'gray'
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
    month: 'short',
    day: 'numeric'
  })
}

onMounted(() => {
  loadExpenses()
})
</script>

<template>
  <UDashboardPanel id="expenses">
    <template #header>
      <UDashboardNavbar title="Gastos">
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
            label="Nuevo Gasto"
            icon="i-lucide-plus"
            to="/expenses/new"
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
            v-model="filters.category"
            :options="categoryOptions"
            placeholder="Categoría"
            class="w-48"
          />
          <USelect
            v-model="filters.paymentSource"
            :options="paymentSourceOptions"
            placeholder="Fuente de pago"
            class="w-48"
          />
          <UButton @click="loadExpenses" icon="i-lucide-filter">Filtrar</UButton>
          <UButton color="neutral" variant="ghost" @click="clearFilters">Limpiar</UButton>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <div class="space-y-6">
        <!-- Resumen -->
        <div v-if="summary" class="grid gap-4 sm:grid-cols-2">
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Total Gastos</p>
              <p class="text-3xl font-bold text-red-600 mt-1">${{ formatCurrency(summary.total_expenses || 0) }}</p>
            </div>
          </UCard>
          <UCard>
            <div class="text-center">
              <p class="text-sm text-gray-500 dark:text-gray-400">Cantidad</p>
              <p class="text-3xl font-bold mt-1">{{ summary.count || 0 }}</p>
            </div>
          </UCard>
        </div>

        <!-- Tabla -->
        <UCard>
          <template #header>
            <h3 class="text-lg font-semibold">Lista de Gastos</h3>
          </template>

          <UTable
            v-if="!loading && expenses.length > 0"
            :rows="expenses"
            :columns="columns"
          >
            <template #expense_date-data="{ row }">
              {{ formatDate(row.expense_date) }}
            </template>

            <template #amount-data="{ row }">
              <span class="font-semibold text-red-600">${{ formatCurrency(row.amount) }}</span>
            </template>

            <template #category-data="{ row }">
              <UBadge :color="getCategoryColor(row.cost_type)" variant="subtle">
                {{ getCategoryLabel(row.category) }}
              </UBadge>
            </template>

            <template #payment_source-data="{ row }">
              <span class="text-sm">{{ getPaymentSourceLabel(row.payment_source) }}</span>
            </template>

            <template #requires_reimbursement-data="{ row }">
              <UBadge v-if="row.requires_reimbursement && !row.reimbursed" color="amber" variant="subtle">
                Pendiente
              </UBadge>
              <UBadge v-else-if="row.requires_reimbursement && row.reimbursed" color="green" variant="subtle">
                Reembolsado
              </UBadge>
              <span v-else class="text-gray-400">-</span>
            </template>

            <template #actions-data="{ row }">
              <UDropdownMenu
                :items="[[
                  { label: 'Eliminar', icon: 'i-lucide-trash', click: () => deleteExpense(row.id) }
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
            <p class="text-gray-500">No hay gastos registrados</p>
            <UButton to="/expenses/new" class="mt-4">Registrar primer gasto</UButton>
          </div>
        </UCard>
      </div>
    </template>
  </UDashboardPanel>
</template>
