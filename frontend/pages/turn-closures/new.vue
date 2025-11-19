<template>
  <div>
    <div class="mb-8">
      <UButton 
        to="/turn-closures" 
        variant="ghost" 
        icon="i-heroicons-arrow-left"
        class="mb-4"
      >
        Volver
      </UButton>
      <h1 class="text-3xl font-bold text-gray-900">Nuevo Cierre de Turno</h1>
      <p class="text-gray-600 mt-2">Registra un cierre de caja del ticket de Loyverse</p>
    </div>

    <UCard>
      <UForm :state="form" @submit="onSubmit" class="space-y-6">
        <div class="grid md:grid-cols-2 gap-6">
          <!-- Número de cierre -->
          <UFormGroup label="Número de cierre de caja *" name="closure_number" required>
            <UInput 
              v-model.number="form.closure_number" 
              type="number" 
              placeholder="59"
              size="lg"
            />
            <template #help>
              Del ticket de Loyverse
            </template>
          </UFormGroup>

          <!-- Fecha del reporte -->
          <UFormGroup label="Fecha del reporte *" name="report_date" required>
            <UInput 
              v-model="form.report_date" 
              type="date" 
              size="lg"
            />
            <template #help>
              Cuando abrió el turno
            </template>
          </UFormGroup>

          <!-- Cerrado por -->
          <UFormGroup label="Cerrado por *" name="closed_by" required>
            <USelect 
              v-model="form.closed_by" 
              :options="employeeOptions"
              size="lg"
            />
          </UFormGroup>

          <!-- Cobros en efectivo -->
          <UFormGroup label="Cobros en efectivo *" name="cash_collected" required>
            <UInput 
              v-model.number="form.cash_collected" 
              type="number" 
              step="0.01"
              placeholder="2250.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <!-- Ingresos por transferencia -->
          <UFormGroup label="Ingresos por transferencia (brutos) *" name="transfer_income" required>
            <UInput 
              v-model.number="form.transfer_income" 
              type="number" 
              step="0.01"
              placeholder="550.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <!-- Ingresos por tarjeta -->
          <UFormGroup label="Ingresos por tarjeta (brutos) *" name="card_income" required>
            <UInput 
              v-model.number="form.card_income" 
              type="number" 
              step="0.01"
              placeholder="475.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <!-- Efectivo teórico -->
          <UFormGroup label="Efectivo teórico *" name="theoretical_cash" required>
            <UInput 
              v-model.number="form.theoretical_cash" 
              type="number" 
              step="0.01"
              placeholder="3136.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
            <template #help>
              Del ticket de Loyverse
            </template>
          </UFormGroup>

          <!-- Pagos/Salidas -->
          <UFormGroup label="Pagos/Salidas *" name="payments_withdrawals" required>
            <UInput 
              v-model.number="form.payments_withdrawals" 
              type="number" 
              step="0.01"
              placeholder="114.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
            <template #help>
              Del ticket de Loyverse
            </template>
          </UFormGroup>
        </div>

        <!-- Notas -->
        <UFormGroup label="Notas (opcional)" name="notes">
          <UTextarea 
            v-model="form.notes" 
            rows="3"
            placeholder="Observaciones adicionales..."
          />
        </UFormGroup>

        <!-- Resumen calculado -->
        <div class="p-4 bg-green-50 rounded-lg border border-green-200">
          <h3 class="font-semibold mb-2">Resumen</h3>
          <div class="grid md:grid-cols-3 gap-4 text-sm">
            <div>
              <p class="text-gray-600">Total de ingresos</p>
              <p class="text-xl font-bold text-green-600">${{ formatCurrency(totalIncome) }}</p>
            </div>
            <div>
              <p class="text-gray-600">Efectivo final (Caja Chica)</p>
              <p class="text-xl font-bold">${{ formatCurrency(finalCash) }}</p>
            </div>
            <div>
              <p class="text-gray-600">Ingresos digitales</p>
              <p class="text-xl font-bold">${{ formatCurrency(digitalIncome) }}</p>
            </div>
          </div>
        </div>

        <!-- Botones -->
        <div class="flex gap-4">
          <UButton 
            type="submit" 
            size="lg"
            :loading="loading"
          >
            Guardar Cierre
          </UButton>
          <UButton 
            to="/turn-closures" 
            color="white" 
            size="lg"
          >
            Cancelar
          </UButton>
        </div>
      </UForm>
    </UCard>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const api = useApi()
const router = useRouter()
const toast = useToast()

const loading = ref(false)

const form = reactive({
  closure_number: null,
  report_date: '',
  closed_by: 'David',
  cash_collected: 0,
  transfer_income: 0,
  card_income: 0,
  theoretical_cash: 0,
  payments_withdrawals: 0,
  notes: ''
})

const employeeOptions = [
  { label: 'David', value: 'David' },
  { label: 'Daniel', value: 'Daniel' },
  { label: 'Raúl', value: 'Raúl' },
  { label: 'Yahir', value: 'Yahir' }
]

const totalIncome = computed(() => {
  return form.cash_collected + form.transfer_income + form.card_income
})

const digitalIncome = computed(() => {
  return form.transfer_income + form.card_income
})

const finalCash = computed(() => {
  return 1000 + form.cash_collected - form.payments_withdrawals
})

const onSubmit = async () => {
  loading.value = true
  try {
    await api.post('/turn_closures', form)
    toast.add({
      title: 'Éxito',
      description: 'Cierre registrado correctamente',
      color: 'green'
    })
    router.push('/turn-closures')
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.data?.message || 'No se pudo guardar el cierre',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

// Set today's date by default
onMounted(() => {
  form.report_date = new Date().toISOString().split('T')[0]
})
</script>
