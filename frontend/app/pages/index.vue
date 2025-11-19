<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()

const period = ref('month')
const customDateRange = ref(false)
const dateFrom = ref('')
const dateTo = ref('')

const periodOptions = [
  { label: 'Hoy', value: 'day' },
  { label: 'Esta Semana', value: 'week' },
  { label: 'Este Mes', value: 'month' },
  { label: 'Personalizado', value: 'custom' }
]

const currentPeriod = computed(() => {
  if (period.value === 'custom') {
    return customDateRange.value ? `${dateFrom.value} - ${dateTo.value}` : 'Selecciona rango'
  }
  return periodOptions.find(p => p.value === period.value)?.label || ''
})

watch(period, (newPeriod) => {
  customDateRange.value = newPeriod === 'custom'
})
</script>

<template>
  <UDashboardPanel id="dashboard">
    <template #header>
      <UDashboardNavbar title="Dashboard" :ui="{ right: 'gap-3' }">
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
              <UIcon name="i-lucide-bell" class="size-5 shrink-0" />
            </UButton>
          </UTooltip>

          <UButton
            label="Nuevo Cierre"
            icon="i-lucide-plus"
            size="md"
            to="/turn-closures/new"
            class="hidden lg:inline-flex"
          />
        </template>
      </UDashboardNavbar>

      <UDashboardToolbar>
        <template #left>
          <USelect
            v-model="period"
            :options="periodOptions"
            size="md"
            variant="subtle"
            class="w-48"
          />

          <div v-if="customDateRange" class="flex items-center gap-2">
            <UInput
              v-model="dateFrom"
              type="date"
              size="md"
              placeholder="Desde"
              class="w-40"
            />
            <span class="text-gray-400">→</span>
            <UInput
              v-model="dateTo"
              type="date"
              size="md"
              placeholder="Hasta"
              class="w-40"
            />
          </div>
        </template>

        <template #right>
          <div class="flex items-center gap-3">
            <UBadge color="green" variant="subtle" size="lg">
              {{ currentPeriod }}
            </UBadge>
          </div>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <div class="space-y-8">
        <!-- Alertas de reembolsos pendientes -->
        <DashboardReimbursementsAlert />

        <!-- Saldos de cuentas -->
        <DashboardAccountsCards />

        <!-- Métricas del período -->
        <DashboardMetricsCards :period="period" />

        <!-- Desglose de gastos -->
        <DashboardExpenseBreakdown :period="period" />
      </div>
    </template>
  </UDashboardPanel>
</template>
