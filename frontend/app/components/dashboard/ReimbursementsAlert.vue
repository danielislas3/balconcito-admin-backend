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
        to: '/reimbursements'
      }]"
    >
      <template #description>
        <div class="mt-2 space-y-1">
          <div v-if="pendingReimbursements.daniel?.total_amount > 0" class="flex justify-between text-sm">
            <span>Daniel:</span>
            <span class="font-semibold">${{ formatCurrency(pendingReimbursements.daniel.total_amount) }}</span>
          </div>
          <div v-if="pendingReimbursements.raul?.total_amount > 0" class="flex justify-between text-sm">
            <span>Raúl:</span>
            <span class="font-semibold">${{ formatCurrency(pendingReimbursements.raul.total_amount) }}</span>
          </div>
        </div>
      </template>
    </UAlert>
  </div>
</template>
