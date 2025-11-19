<template>
  <div>
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Cuentas</h1>
      <p class="text-gray-600 mt-2">Gestión de saldos de cuentas</p>
    </div>

    <!-- Tarjetas de cuentas -->
    <div v-if="loading" class="grid gap-6 md:grid-cols-3">
      <USkeleton class="h-48" v-for="i in 3" :key="i" />
    </div>

    <div v-else class="grid gap-6 md:grid-cols-3 mb-8">
      <UCard v-for="account in accounts" :key="account.id">
        <template #header>
          <div class="flex items-center justify-between">
            <h3 class="font-semibold text-lg">{{ account.name }}</h3>
            <UBadge :color="getAccountColor(account.account_type)" size="lg">
              {{ getAccountTypeLabel(account.account_type) }}
            </UBadge>
          </div>
        </template>

        <div class="mb-4">
          <p class="text-sm text-gray-600 mb-2">Saldo Actual</p>
          <p class="text-4xl font-bold text-green-600">
            ${{ formatCurrency(account.current_balance) }}
          </p>
        </div>

        <div v-if="account.description" class="mb-4 text-sm text-gray-600">
          {{ account.description }}
        </div>

        <UButton 
          @click="openEditModal(account)" 
          variant="outline" 
          block
        >
          Ajustar Saldo
        </UButton>
      </UCard>
    </div>

    <!-- Resumen total -->
    <UCard class="mb-8">
      <template #header>
        <h3 class="font-semibold text-lg">Resumen Total</h3>
      </template>
      
      <div class="grid md:grid-cols-4 gap-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Total Disponible</p>
          <p class="text-3xl font-bold text-green-600">
            ${{ formatCurrency(totalBalance) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Mercado Pago</p>
          <p class="text-2xl font-bold">
            ${{ formatCurrency(getAccountBalance('Mercado Pago')) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Bóveda</p>
          <p class="text-2xl font-bold">
            ${{ formatCurrency(getAccountBalance('Bóveda')) }}
          </p>
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Caja Chica</p>
          <p class="text-2xl font-bold">
            ${{ formatCurrency(getAccountBalance('Caja Chica')) }}
          </p>
        </div>
      </div>
    </UCard>

    <!-- Información sobre cuentas -->
    <UCard>
      <template #header>
        <h3 class="font-semibold text-lg">Información sobre las Cuentas</h3>
      </template>
      
      <div class="space-y-4 text-sm">
        <div class="p-4 bg-blue-50 rounded-lg">
          <h4 class="font-semibold mb-2 text-blue-900">💳 Mercado Pago (Cuenta Digital)</h4>
          <p class="text-gray-700">
            Aquí llegan las transferencias directas (QR/CVU) al 100% y los pagos con tarjeta (con comisión descontada). 
            Es tu "bóveda digital".
          </p>
        </div>

        <div class="p-4 bg-green-50 rounded-lg">
          <h4 class="font-semibold mb-2 text-green-900">💰 Bóveda (Efectivo Guardado)</h4>
          <p class="text-gray-700">
            Todo el efectivo acumulado del negocio. De aquí se sacan $1,000 para el fondo de caja chica cada día 
            y se pagan compras grandes (cerveza, insumos mayores).
          </p>
        </div>

        <div class="p-4 bg-amber-50 rounded-lg">
          <h4 class="font-semibold mb-2 text-amber-900">🏪 Caja Chica (Efectivo Operativo)</h4>
          <p class="text-gray-700">
            Siempre tiene un fondo fijo de $1,000 pesos más el efectivo de las ventas del día. 
            De aquí se pagan gastos pequeños del día (hielo, agua, etc.).
          </p>
        </div>
      </div>
    </UCard>

    <!-- Modal de edición -->
    <UModal v-model="showEditModal">
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Ajustar Saldo: {{ selectedAccount?.name }}</h3>
        </template>

        <UForm :state="editForm" @submit="updateAccount" class="space-y-4">
          <UFormGroup label="Saldo Actual">
            <UInput 
              :model-value="formatCurrency(selectedAccount?.current_balance || 0)" 
              disabled
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <UFormGroup label="Nuevo Saldo" required>
            <UInput 
              v-model.number="editForm.current_balance" 
              type="number" 
              step="0.01"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <UFormGroup label="Notas / Razón del ajuste" required>
            <UTextarea 
              v-model="editForm.notes" 
              rows="3"
              placeholder="Ej: Retiro de $5,000 para pagar proveedor"
            />
          </UFormGroup>

          <UAlert
            color="amber"
            icon="i-heroicons-exclamation-triangle"
            title="Importante"
            description="Los ajustes manuales deben hacerse con cuidado. Asegúrate de que el nuevo saldo refleje la realidad."
          />

          <div class="flex gap-4">
            <UButton type="submit" :loading="submitting" class="flex-1">
              Guardar Cambios
            </UButton>
            <UButton color="white" @click="showEditModal = false">
              Cancelar
            </UButton>
          </div>
        </UForm>
      </UCard>
    </UModal>
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
const accounts = ref<any[]>([])
const showEditModal = ref(false)
const submitting = ref(false)
const selectedAccount = ref<any>(null)

const editForm = reactive({
  current_balance: 0,
  notes: ''
})

const loadAccounts = async () => {
  loading.value = true
  try {
    const data: any = await api.get('/accounts')
    accounts.value = data.accounts
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar las cuentas',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

const totalBalance = computed(() => {
  return accounts.value.reduce((sum, acc) => sum + acc.current_balance, 0)
})

const getAccountBalance = (name: string) => {
  const account = accounts.value.find(acc => acc.name === name)
  return account?.current_balance || 0
}

const openEditModal = (account: any) => {
  selectedAccount.value = account
  editForm.current_balance = account.current_balance
  editForm.notes = ''
  showEditModal.value = true
}

const updateAccount = async () => {
  submitting.value = true
  try {
    await api.patch(`/accounts/${selectedAccount.value.id}`, editForm)
    toast.add({
      title: 'Éxito',
      description: 'Saldo actualizado correctamente',
      color: 'green'
    })
    showEditModal.value = false
    loadAccounts()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.data?.message || 'No se pudo actualizar el saldo',
      color: 'red'
    })
  } finally {
    submitting.value = false
  }
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

onMounted(() => {
  loadAccounts()
})

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}
</script>
