<script setup lang="ts">
interface Props {
  period?: string
}

const props = withDefaults(defineProps<Props>(), {
  period: 'month'
})

const api = useApi()

const summary = ref<any>(null)
const profitability = ref<any>(null)
const breakEven = ref<any>(null)
const cashFlow = ref<any>(null)
const loading = ref(true)

const loadMetrics = async () => {
  loading.value = true
  try {
    const [summaryData, profitabilityData, breakEvenData, cashFlowData] = await Promise.all([
      api.get(`/dashboard/summary?period=${props.period}`),
      api.get(`/dashboard/profitability?period=${props.period}`),
      api.get(`/dashboard/break_even?period=${props.period}`),
      api.get(`/dashboard/cash_flow?period=${props.period}`)
    ])

    summary.value = summaryData
    profitability.value = profitabilityData
    breakEven.value = breakEvenData
    cashFlow.value = cashFlowData
  } catch (error) {
    console.error('Error loading metrics:', error)
  } finally {
    loading.value = false
  }
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatPercentage = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const getCogsStatus = (value: number) => {
  if (value <= 30) return { color: 'green' as const, label: 'Excelente' }
  if (value <= 40) return { color: 'amber' as const, label: 'Aceptable' }
  return { color: 'red' as const, label: 'Alto' }
}

const getCashRunwayStatus = (days: number) => {
  if (days >= 30) return { color: 'green' as const, label: 'Saludable' }
  if (days >= 15) return { color: 'amber' as const, label: 'Advertencia' }
  return { color: 'red' as const, label: 'Crítico' }
}

watch(() => props.period, () => {
  loadMetrics()
})

onMounted(() => {
  loadMetrics()
})
</script>

<template>
  <div>
    <h2 class="text-lg font-semibold mb-4">Métricas del Período</h2>

    <div v-if="loading" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <USkeleton class="h-40" v-for="i in 6" :key="i" />
    </div>

    <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      <!-- Ingresos Totales -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Ingresos Totales</h3>
            <UTooltip text="Todo el dinero que entró por ventas en el período seleccionado">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UIcon name="i-lucide-trending-up" class="size-5 text-green-500" />
        </div>
        <p class="text-3xl font-bold text-green-600">${{ formatCurrency(summary?.income?.total || 0) }}</p>
        <div class="mt-3 space-y-1 text-xs text-gray-500">
          <div class="flex justify-between">
            <span>Efectivo:</span>
            <span class="font-medium">${{ formatCurrency(summary?.income?.cash || 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Transferencias:</span>
            <span class="font-medium">${{ formatCurrency(summary?.income?.transfers || 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Tarjetas:</span>
            <span class="font-medium">${{ formatCurrency(summary?.income?.cards || 0) }}</span>
          </div>
        </div>
      </UCard>

      <!-- Gastos Totales -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Gastos Totales</h3>
            <UTooltip text="Todo lo que gastaste en el período (insumos, nómina, servicios, etc.)">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UIcon name="i-lucide-trending-down" class="size-5 text-red-500" />
        </div>
        <p class="text-3xl font-bold text-red-600">${{ formatCurrency(summary?.expenses?.total || 0) }}</p>
        <div class="mt-3 space-y-1 text-xs text-gray-500">
          <div class="flex justify-between">
            <span>COGS:</span>
            <span class="font-medium">${{ formatCurrency(summary?.expenses?.cogs || 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Fijos:</span>
            <span class="font-medium">${{ formatCurrency(summary?.expenses?.fixed || 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Variables:</span>
            <span class="font-medium">${{ formatCurrency(summary?.expenses?.variable || 0) }}</span>
          </div>
        </div>
      </UCard>

      <!-- Utilidad Neta -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Utilidad Neta</h3>
            <UTooltip text="Tu ganancia real después de pagar TODO (Ingresos - Gastos)">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UIcon
            :name="summary?.balance >= 0 ? 'i-lucide-circle-check' : 'i-lucide-circle-x'"
            :class="summary?.balance >= 0 ? 'text-green-500' : 'text-red-500'"
            class="size-5"
          />
        </div>
        <p class="text-3xl font-bold" :class="summary?.balance >= 0 ? 'text-green-600' : 'text-red-600'">
          ${{ formatCurrency(summary?.balance || 0) }}
        </p>
        <div class="mt-3 text-xs text-gray-500">
          <div class="flex justify-between">
            <span>Margen Neto:</span>
            <span class="font-medium">{{ formatPercentage(profitability?.metrics?.net_margin?.value || 0) }}%</span>
          </div>
          <p class="mt-1 text-gray-400">
            De cada peso, {{ formatPercentage(profitability?.metrics?.net_margin?.value || 0) }}¢ son ganancia
          </p>
        </div>
      </UCard>

      <!-- COGS % -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">COGS %</h3>
            <UTooltip text="Cuánto te cuestan los productos que vendes (cerveza, comida, hielo, etc.) como % de tus ventas. Ideal: 25-35%">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UBadge
            :color="getCogsStatus(profitability?.metrics?.cogs_percentage?.value || 0).color"
            variant="subtle"
          >
            {{ getCogsStatus(profitability?.metrics?.cogs_percentage?.value || 0).label }}
          </UBadge>
        </div>
        <p class="text-3xl font-bold">
          {{ formatPercentage(profitability?.metrics?.cogs_percentage?.value || 0) }}%
        </p>
        <div class="mt-3 text-xs text-gray-500">
          <div class="flex justify-between">
            <span>Total COGS:</span>
            <span class="font-medium">${{ formatCurrency(profitability?.metrics?.cogs_percentage?.amount || 0) }}</span>
          </div>
          <p class="mt-1 text-gray-400">
            Por cada peso vendido, gastas {{ formatPercentage(profitability?.metrics?.cogs_percentage?.value || 0) }}¢ en insumos
          </p>
        </div>
      </UCard>

      <!-- Punto de Equilibrio -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Punto de Equilibrio</h3>
            <UTooltip text="Lo mínimo que necesitas vender para NO perder dinero (ni ganar ni perder)">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UIcon name="i-lucide-target" class="size-5 text-blue-500" />
        </div>
        <p class="text-3xl font-bold text-blue-600">
          ${{ formatCurrency(breakEven?.metrics?.break_even_point?.value || 0) }}
        </p>
        <div class="mt-3 text-xs text-gray-500">
          <div class="flex justify-between mb-1">
            <span>Ventas actuales:</span>
            <span class="font-medium">${{ formatCurrency(breakEven?.metrics?.current_sales || 0) }}</span>
          </div>
          <div v-if="breakEven?.metrics?.safety_margin" class="flex justify-between">
            <span>Margen de seguridad:</span>
            <span class="font-medium text-green-600">
              +${{ formatCurrency(breakEven.metrics.safety_margin.value) }}
            </span>
          </div>
          <p class="mt-1 text-gray-400">
            Llegas al punto de equilibrio en {{ breakEven?.metrics?.days_to_break_even || 0 }} días
          </p>
        </div>
      </UCard>

      <!-- Cash Runway -->
      <UCard>
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">Cash Runway</h3>
            <UTooltip text="Días que podrías operar si tus ventas bajaran a cero mañana. Es tu colchón de seguridad">
              <UIcon name="i-lucide-info" class="size-4 text-gray-400 cursor-help" />
            </UTooltip>
          </div>
          <UBadge
            :color="getCashRunwayStatus(cashFlow?.metrics?.cash_runway_days?.value || 0).color"
            variant="subtle"
          >
            {{ getCashRunwayStatus(cashFlow?.metrics?.cash_runway_days?.value || 0).label }}
          </UBadge>
        </div>
        <p class="text-3xl font-bold text-purple-600">
          {{ cashFlow?.metrics?.cash_runway_days?.value || 0 }} días
        </p>
        <div class="mt-3 text-xs text-gray-500">
          <div class="flex justify-between mb-1">
            <span>Gasto diario promedio:</span>
            <span class="font-medium">${{ formatCurrency(cashFlow?.metrics?.average_daily_expenses || 0) }}</span>
          </div>
          <div class="flex justify-between">
            <span>Efectivo disponible:</span>
            <span class="font-medium">${{ formatCurrency(cashFlow?.cash_accounts?.total_cash || 0) }}</span>
          </div>
          <p class="mt-1 text-gray-400">
            {{ cashFlow?.explanation || 'Con el efectivo actual y gastos promedio' }}
          </p>
        </div>
      </UCard>
    </div>
  </div>
</template>
