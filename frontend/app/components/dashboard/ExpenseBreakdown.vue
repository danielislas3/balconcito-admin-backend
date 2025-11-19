<script setup lang="ts">
interface Props {
  period?: string
}

const props = withDefaults(defineProps<Props>(), {
  period: 'month'
})

const api = useApi()

const breakdown = ref<any>(null)
const loading = ref(true)

const loadBreakdown = async () => {
  loading.value = true
  try {
    const data = await api.get(`/dashboard/expense_breakdown?period=${props.period}`)
    breakdown.value = data
  } catch (error) {
    console.error('Error loading expense breakdown:', error)
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
    minimumFractionDigits: 1,
    maximumFractionDigits: 1
  }).format(value || 0)
}

const getCostTypeColor = (costType: string) => {
  const colors: Record<string, string> = {
    cogs: 'amber',
    fixed: 'red',
    variable: 'blue'
  }
  return colors[costType] || 'gray'
}

const getCostTypeLabel = (costType: string) => {
  const labels: Record<string, string> = {
    cogs: 'COGS',
    fixed: 'Fijos',
    variable: 'Variables'
  }
  return labels[costType] || costType
}

const getCategoryLabel = (category: string) => {
  const labels: Record<string, string> = {
    cerveza: 'Cerveza',
    cerveza_barril: 'Cerveza de Barril',
    vinos_licores: 'Vinos y Licores',
    refrescos_jugos: 'Refrescos y Jugos',
    alimentos: 'Alimentos',
    desechables: 'Desechables',
    hielo: 'Hielo',
    insumos_secos: 'Insumos Secos',
    renta: 'Renta',
    nomina: 'Nómina',
    servicios: 'Servicios',
    gastos_financieros: 'Gastos Financieros',
    pago_deuda: 'Pago de Deuda',
    mantenimiento: 'Mantenimiento',
    gastos_staff: 'Gastos de Staff',
    gastos_varios: 'Gastos Varios'
  }
  return labels[category] || category
}

// Top 5 categorías para mostrar
const topCategories = computed(() => {
  if (!breakdown.value?.by_category) return []
  return breakdown.value.by_category.slice(0, 5)
})

watch(() => props.period, () => {
  loadBreakdown()
})

onMounted(() => {
  loadBreakdown()
})
</script>

<template>
  <div>
    <h2 class="text-lg font-semibold mb-4">Desglose de Gastos</h2>

    <div v-if="loading">
      <USkeleton class="h-96" />
    </div>

    <div v-else class="grid gap-6 lg:grid-cols-2">
      <!-- Por tipo de costo -->
      <UCard>
        <template #header>
          <h3 class="font-semibold">Por Tipo de Costo</h3>
        </template>

        <div v-if="breakdown?.by_cost_type" class="space-y-4">
          <div
            v-for="(data, costType) in breakdown.by_cost_type"
            :key="costType"
            class="space-y-2"
          >
            <div class="flex items-center justify-between text-sm">
              <div class="flex items-center gap-2">
                <UBadge
                  :color="getCostTypeColor(costType as string)"
                  variant="subtle"
                >
                  {{ getCostTypeLabel(costType as string) }}
                </UBadge>
                <span class="text-gray-600 dark:text-gray-400">
                  {{ formatPercentage(data.percentage) }}%
                </span>
              </div>
              <span class="font-semibold">
                ${{ formatCurrency(data.amount) }}
              </span>
            </div>

            <!-- Barra de progreso -->
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div
                :class="`bg-${getCostTypeColor(costType as string)}-500 h-2 rounded-full`"
                :style="{ width: `${data.percentage}%` }"
              />
            </div>

            <p class="text-xs text-gray-500">
              {{ data.description }}
            </p>
          </div>
        </div>

        <div v-else class="text-center py-8 text-gray-500">
          No hay datos de gastos para este período
        </div>
      </UCard>

      <!-- Top categorías -->
      <UCard>
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="font-semibold">Top 5 Categorías</h3>
            <span class="text-sm text-gray-500">
              Total: ${{ formatCurrency(breakdown?.total_expenses || 0) }}
            </span>
          </div>
        </template>

        <div v-if="topCategories.length > 0" class="space-y-3">
          <div
            v-for="category in topCategories"
            :key="category.category"
            class="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-900 rounded-lg"
          >
            <div class="flex-1">
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm font-medium">
                  {{ getCategoryLabel(category.category) }}
                </span>
                <span class="text-sm font-bold">
                  ${{ formatCurrency(category.amount) }}
                </span>
              </div>
              <div class="flex items-center gap-2 text-xs text-gray-500">
                <span>{{ formatPercentage(category.percentage) }}%</span>
                <span>•</span>
                <span>{{ category.count }} {{ category.count === 1 ? 'gasto' : 'gastos' }}</span>
                <UBadge
                  :color="getCostTypeColor(category.cost_type)"
                  size="xs"
                  variant="subtle"
                >
                  {{ getCostTypeLabel(category.cost_type) }}
                </UBadge>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="text-center py-8 text-gray-500">
          No hay gastos registrados
        </div>
      </UCard>
    </div>
  </div>
</template>
