<script setup lang="ts">
const api = useApi()

const pendingReimbursements = ref<any>(null)
const loading = ref(true)

const loadPendingReimbursements = async () => {
  try {
    const data: any = await api.get('/expenses/pending_reimbursement')
    pendingReimbursements.value = data.pending_reimbursements
  } catch (error) {
    console.error('Error loading pending reimbursements:', error)
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

const totalPending = computed(() => {
  if (!pendingReimbursements.value) return 0
  return (pendingReimbursements.value.daniel?.total_amount || 0) +
         (pendingReimbursements.value.raul?.total_amount || 0)
})

onMounted(() => {
  loadPendingReimbursements()
})
</script>

<template>
  <div v-if="!loading && totalPending > 0">
    <UAlert
      color="amber"
      icon="i-lucide-alert-circle"
      :title="`Reembolsos Pendientes: $${formatCurrency(totalPending)}`"
      :actions="[{
        label: 'Ver Reembolsos',
        to: '/reimbursements',
        icon: 'i-lucide-arrow-right'
      }]"
    >
      <template #description>
        <div class="mt-2 space-y-2">
          <div v-if="pendingReimbursements.daniel?.total_amount > 0" class="p-2 bg-amber-50 dark:bg-amber-900/20 rounded-lg">
            <div class="flex justify-between items-center text-sm">
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-user" class="size-4" />
                <span class="font-medium">Daniel:</span>
              </div>
              <div class="text-right">
                <span class="font-bold">${{ formatCurrency(pendingReimbursements.daniel.total_amount) }}</span>
                <span class="text-xs text-gray-500 ml-2">
                  ({{ pendingReimbursements.daniel.expenses?.length || 0 }} {{ pendingReimbursements.daniel.expenses?.length === 1 ? 'gasto' : 'gastos' }})
                </span>
              </div>
            </div>
          </div>
          <div v-if="pendingReimbursements.raul?.total_amount > 0" class="p-2 bg-amber-50 dark:bg-amber-900/20 rounded-lg">
            <div class="flex justify-between items-center text-sm">
              <div class="flex items-center gap-2">
                <UIcon name="i-lucide-user" class="size-4" />
                <span class="font-medium">Raúl:</span>
              </div>
              <div class="text-right">
                <span class="font-bold">${{ formatCurrency(pendingReimbursements.raul.total_amount) }}</span>
                <span class="text-xs text-gray-500 ml-2">
                  ({{ pendingReimbursements.raul.expenses?.length || 0 }} {{ pendingReimbursements.raul.expenses?.length === 1 ? 'gasto' : 'gastos' }})
                </span>
              </div>
            </div>
          </div>
          <p class="text-xs text-gray-600 dark:text-gray-400 mt-2">
            Gastos realizados con tarjetas personales que requieren reembolso
          </p>
        </div>
      </template>
    </UAlert>
  </div>
</template>
