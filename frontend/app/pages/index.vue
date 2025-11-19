<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()

const period = ref('month')
const periodOptions = [
  { label: 'Hoy', value: 'day' },
  { label: 'Esta Semana', value: 'week' },
  { label: 'Este Mes', value: 'month' }
]
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
            class="w-40"
          />
        </template>

        <template #right>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Sistema de administración Balconcito
          </p>
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

        <!-- Gráfica de ingresos/gastos (pendiente) -->
        <!-- <DashboardChart :period="period" /> -->
      </div>
    </template>
  </UDashboardPanel>
</template>
