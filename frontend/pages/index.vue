<template>
  <div>
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
      <p class="text-gray-600 mt-2">Vista general de tu negocio</p>
    </div>

    <!-- Selector de período -->
    <div class="mb-6 flex gap-4">
      <USelect 
        v-model="selectedPeriod" 
        :options="periodOptions"
        size="lg"
        @change="loadDashboardData"
      />
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
      <USkeleton class="h-32" v-for="i in 6" :key="i" />
    </div>

    <!-- Dashboard content -->
    <div v-else>
      <!-- Cuentas (Saldos actuales) -->
      <div class="mb-8">
        <h2 class="text-xl font-bold text-gray-900 mb-4">Saldos Actuales</h2>
        <div class="grid gap-4 md:grid-cols-3">
          <UCard v-for="account in accounts" :key="account.id">
            <template #header>
              <div class="flex items-center justify-between">
                <h3 class="font-semibold">{{ account.name }}</h3>
                <UBadge :color="getAccountColor(account.account_type)">
                  {{ getAccountTypeLabel(account.account_type) }}
                </UBadge>
              </div>
            </template>
            <div class="text-3xl font-bold text-green-600">
              ${{ formatCurrency(account.current_balance) }}
            </div>
          </UCard>
        </div>
      </div>

      <!-- Métricas principales -->
      <div class="mb-8">
        <h2 class="text-xl font-bold text-gray-900 mb-4">Métricas del Período</h2>
        <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <!-- Ingresos -->
          <UCard>
            <template #header>
              <h3 class="font-semibold text-gray-700">Ingresos Totales</h3>
            </template>
            <div class="text-3xl font-bold text-green-600">
              ${{ formatCurrency(summary?.income?.total || 0) }}
            </div>
            <div class="mt-2 text-sm text-gray-500">
              <div>Efectivo: ${{ formatCurrency(summary?.income?.cash || 0) }}</div>
              <div>Transferencias: ${{ formatCurrency(summary?.income?.transfers || 0) }}</div>
              <div>Tarjetas: ${{ formatCurrency(summary?.income?.cards || 0) }}</div>
            </div>
          </UCard>

          <!-- Gastos -->
          <UCard>
            <template #header>
              <h3 class="font-semibold text-gray-700">Gastos Totales</h3>
            </template>
            <div class="text-3xl font-bold text-red-600">
              ${{ formatCurrency(summary?.expenses?.total || 0) }}
            </div>
            <div class="mt-2 text-sm text-gray-500">
              <div>COGS: ${{ formatCurrency(summary?.expenses?.cogs || 0) }}</div>
              <div>Fijos: ${{ formatCurrency(summary?.expenses?.fixed || 0) }}</div>
              <div>Variables: ${{ formatCurrency(summary?.expenses?.variable || 0) }}</div>
            </div>
          </UCard>

          <!-- Utilidad Neta -->
          <UCard>
            <template #header>
              <h3 class="font-semibold text-gray-700">Utilidad Neta</h3>
            </template>
            <div class="text-3xl font-bold" :class="summary?.balance >= 0 ? 'text-green-600' : 'text-red-600'">
              ${{ formatCurrency(summary?.balance || 0) }}
            </div>
            <div class="mt-2 text-sm text-gray-500">
              Margen: {{ formatPercentage(profitability?.metrics?.net_margin?.value || 0) }}%
            </div>
          </UCard>

          <!-- COGS % -->
          <UCard>
            <template #header>
              <div class="flex items-center justify-between">
                <h3 class="font-semibold text-gray-700">COGS %</h3>
                <UBadge :color="getCogsStatus(profitability?.metrics?.cogs_percentage?.value || 0)">
                  {{ getCogsStatusLabel(profitability?.metrics?.cogs_percentage?.value || 0) }}
                </UBadge>
              </div>
            </template>
            <div class="text-3xl font-bold">
              {{ formatPercentage(profitability?.metrics?.cogs_percentage?.value || 0) }}%
            </div>
            <div class="mt-2 text-sm text-gray-500">
              Costo de Insumos
            </div>
          </UCard>

          <!-- Punto de Equilibrio -->
          <UCard>
            <template #header>
              <h3 class="font-semibold text-gray-700">Punto de Equilibrio</h3>
            </template>
            <div class="text-3xl font-bold text-blue-600">
              ${{ formatCurrency(breakEven?.metrics?.break_even_point?.value || 0) }}
            </div>
            <div class="mt-2 text-sm text-gray-500">
              Ventas actuales: ${{ formatCurrency(breakEven?.metrics?.current_sales || 0) }}
            </div>
          </UCard>

          <!-- Cash Runway -->
          <UCard>
            <template #header>
              <div class="flex items-center justify-between">
                <h3 class="font-semibold text-gray-700">Cash Runway</h3>
                <UBadge :color="getCashRunwayStatus(cashFlow?.metrics?.cash_runway_days?.value || 0)">
                  {{ getCashRunwayStatusLabel(cashFlow?.metrics?.cash_runway_days?.value || 0) }}
                </UBadge>
              </div>
            </template>
            <div class="text-3xl font-bold text-purple-600">
              {{ cashFlow?.metrics?.cash_runway_days?.value || 0 }} días
            </div>
            <div class="mt-2 text-sm text-gray-500">
              Gasto diario: ${{ formatCurrency(cashFlow?.metrics?.average_daily_expenses || 0) }}
            </div>
          </UCard>
        </div>
      </div>

      <!-- Reembolsos pendientes -->
      <div v-if="summary?.pending_reimbursements?.total > 0" class="mb-8">
        <UAlert
          color="amber"
          icon="i-heroicons-exclamation-triangle"
          :title="`Reembolsos Pendientes: $${formatCurrency(summary.pending_reimbursements.total)}`"
        >
          <template #description>
            <div class="mt-2">
              <div v-if="summary.pending_reimbursements.daniel > 0">
                Daniel: ${{ formatCurrency(summary.pending_reimbursements.daniel) }}
              </div>
              <div v-if="summary.pending_reimbursements.raul > 0">
                Raúl: ${{ formatCurrency(summary.pending_reimbursements.raul) }}
              </div>
            </div>
          </template>
        </UAlert>
      </div>
    </div>
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
const selectedPeriod = ref('month')

const periodOptions = [
  { label: 'Hoy', value: 'day' },
  { label: 'Esta Semana', value: 'week' },
  { label: 'Este Mes', value: 'month' }
]

const accounts = ref([])
const summary = ref<any>(null)
const profitability = ref<any>(null)
const breakEven = ref<any>(null)
const cashFlow = ref<any>(null)

const loadDashboardData = async () => {
  loading.value = true
  try {
    const [accountsData, summaryData, profitabilityData, breakEvenData, cashFlowData] = await Promise.all([
      api.get('/accounts'),
      api.get(`/dashboard/summary?period=${selectedPeriod.value}`),
      api.get(`/dashboard/profitability?period=${selectedPeriod.value}`),
      api.get(`/dashboard/break_even?period=${selectedPeriod.value}`),
      api.get(`/dashboard/cash_flow?period=${selectedPeriod.value}`)
    ])

    accounts.value = accountsData.accounts
    summary.value = summaryData
    profitability.value = profitabilityData
    breakEven.value = breakEvenData
    cashFlow.value = cashFlowData
  } catch (error: any) {
    toast.add({
      title: 'Error al cargar datos',
      description: error.data?.message || 'Hubo un error al cargar el dashboard',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboardData()
})

// Helpers
const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

const formatPercentage = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

const getAccountColor = (type: string) => {
  const colors: Record<string, string> = {
    digital: 'blue',
    physical_cash: 'green',
    petty_cash: 'amber'
  }
  return colors[type] || 'gray'
}

const getAccountTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    digital: 'Digital',
    physical_cash: 'Efectivo',
    petty_cash: 'Caja Chica'
  }
  return labels[type] || type
}

const getCogsStatus = (value: number) => {
  if (value <= 30) return 'green'
  if (value <= 40) return 'amber'
  return 'red'
}

const getCogsStatusLabel = (value: number) => {
  if (value <= 30) return 'Excelente'
  if (value <= 40) return 'Aceptable'
  return 'Alto'
}

const getCashRunwayStatus = (days: number) => {
  if (days >= 30) return 'green'
  if (days >= 15) return 'amber'
  return 'red'
}

const getCashRunwayStatusLabel = (days: number) => {
  if (days >= 30) return 'Saludable'
  if (days >= 15) return 'Advertencia'
  return 'Crítico'
}
</script>
