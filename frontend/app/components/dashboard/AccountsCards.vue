<script setup lang="ts">
const api = useApi()

const accounts = ref<any>(null)
const loading = ref(true)

const loadAccounts = async () => {
  loading.value = true
  try {
    const data: any = await api.get('/accounts')
    accounts.value = data
  } catch (error) {
    console.error('Error loading accounts:', error)
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

const getAccountIcon = (accountType: string) => {
  const icons: Record<string, string> = {
    digital: 'i-lucide-smartphone',
    physical_cash: 'i-lucide-vault',
    petty_cash: 'i-lucide-wallet'
  }
  return icons[accountType] || 'i-lucide-circle-dollar-sign'
}

const getAccountColor = (accountType: string) => {
  const colors: Record<string, string> = {
    digital: 'text-blue-500',
    physical_cash: 'text-green-500',
    petty_cash: 'text-amber-500'
  }
  return colors[accountType] || 'text-gray-500'
}

onMounted(() => {
  loadAccounts()
})
</script>

<template>
  <div>
    <h2 class="text-lg font-semibold mb-4">Saldos de Cuentas</h2>

    <div v-if="loading" class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <USkeleton class="h-32" v-for="i in 4" :key="i" />
    </div>

    <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <!-- Cuentas individuales -->
      <UCard v-for="account in accounts?.accounts" :key="account.id">
        <div class="flex items-start justify-between mb-3">
          <div class="flex items-center gap-2">
            <UIcon
              :name="getAccountIcon(account.account_type)"
              :class="getAccountColor(account.account_type)"
              class="size-5"
            />
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">
              {{ account.name }}
            </h3>
          </div>
        </div>
        <p class="text-2xl font-bold" :class="getAccountColor(account.account_type)">
          ${{ formatCurrency(account.current_balance) }}
        </p>
        <div v-if="account.description" class="mt-2 text-xs text-gray-500">
          {{ account.description }}
        </div>
      </UCard>

      <!-- Total consolidado -->
      <UCard class="bg-gradient-to-br from-green-50 to-green-100 dark:from-green-900/20 dark:to-green-800/20">
        <div class="flex items-start justify-between mb-3">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-landmark" class="size-5 text-green-600" />
            <h3 class="text-sm font-medium text-gray-700 dark:text-gray-300">
              Total Disponible
            </h3>
          </div>
        </div>
        <p class="text-2xl font-bold text-green-600">
          ${{ formatCurrency(accounts?.total_balance || 0) }}
        </p>
        <div class="mt-2 text-xs text-gray-500">
          Suma de todas las cuentas
        </div>
      </UCard>
    </div>
  </div>
</template>
