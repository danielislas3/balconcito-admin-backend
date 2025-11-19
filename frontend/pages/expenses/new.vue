<template>
  <div>
    <div class="mb-8">
      <UButton 
        to="/expenses" 
        variant="ghost" 
        icon="i-heroicons-arrow-left"
        class="mb-4"
      >
        Volver
      </UButton>
      <h1 class="text-3xl font-bold text-gray-900">Nuevo Gasto</h1>
      <p class="text-gray-600 mt-2">Registra un gasto del negocio</p>
    </div>

    <UCard>
      <UForm :state="form" @submit="onSubmit" class="space-y-6">
        <div class="grid md:grid-cols-2 gap-6">
          <!-- Fecha del gasto -->
          <UFormGroup label="Fecha del gasto *" name="expense_date" required>
            <UInput 
              v-model="form.expense_date" 
              type="date" 
              size="lg"
            />
          </UFormGroup>

          <!-- Monto -->
          <UFormGroup label="Monto *" name="amount" required>
            <UInput 
              v-model.number="form.amount" 
              type="number" 
              step="0.01"
              placeholder="3633.00"
              size="lg"
            >
              <template #leading>
                <span class="text-gray-500">$</span>
              </template>
            </UInput>
          </UFormGroup>

          <!-- Categoría -->
          <UFormGroup label="Categoría *" name="category" required>
            <USelect 
              v-model="form.category" 
              :options="categoryOptions"
              size="lg"
            />
          </UFormGroup>

          <!-- Fuente de pago -->
          <UFormGroup label="Fuente de pago *" name="payment_source" required>
            <USelect 
              v-model="form.payment_source" 
              :options="paymentSourceOptions"
              size="lg"
            />
            <template #help>
              <span v-if="requiresReimbursement" class="text-amber-600">
                ⚠️ Este gasto requerirá reembolso
              </span>
            </template>
          </UFormGroup>

          <!-- Proveedor -->
          <UFormGroup label="Proveedor (opcional)" name="provider">
            <UInput 
              v-model="form.provider" 
              placeholder="Central"
              size="lg"
            />
          </UFormGroup>

          <!-- URL de foto de ticket -->
          <UFormGroup label="URL de foto del ticket (opcional)" name="receipt_photo_url">
            <UInput 
              v-model="form.receipt_photo_url" 
              type="url"
              placeholder="https://..."
              size="lg"
            />
          </UFormGroup>
        </div>

        <!-- Descripción -->
        <UFormGroup label="Descripción *" name="description" required>
          <UTextarea 
            v-model="form.description" 
            rows="3"
            placeholder="Cerveza corona 24 botellas"
          />
        </UFormGroup>

        <!-- Alerta si requiere reembolso -->
        <UAlert
          v-if="requiresReimbursement"
          color="amber"
          icon="i-heroicons-exclamation-triangle"
          title="Este gasto requiere reembolso"
          description="Se ha pagado con una tarjeta personal. Deberás crear un reembolso después."
        />

        <!-- Resumen -->
        <div class="p-4 bg-blue-50 rounded-lg border border-blue-200">
          <h3 class="font-semibold mb-2">Resumen del gasto</h3>
          <div class="grid md:grid-cols-3 gap-4 text-sm">
            <div>
              <p class="text-gray-600">Monto</p>
              <p class="text-xl font-bold text-red-600">${{ formatCurrency(form.amount) }}</p>
            </div>
            <div>
              <p class="text-gray-600">Tipo de costo</p>
              <p class="text-xl font-bold">{{ getCostTypeLabel(form.category) }}</p>
            </div>
            <div>
              <p class="text-gray-600">Cuenta afectada</p>
              <p class="text-xl font-bold">{{ getAffectedAccount(form.payment_source) }}</p>
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
            Guardar Gasto
          </UButton>
          <UButton 
            to="/expenses" 
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
  expense_date: '',
  amount: 0,
  description: '',
  category: 'cerveza',
  payment_source: 'efectivo_boveda',
  provider: '',
  receipt_photo_url: ''
})

const categoryOptions = [
  { label: 'Cerveza', value: 'cerveza' },
  { label: 'Cerveza de Barril', value: 'cerveza_barril' },
  { label: 'Vinos y Licores', value: 'vinos_licores' },
  { label: 'Refrescos y Jugos', value: 'refrescos_jugos' },
  { label: 'Alimentos', value: 'alimentos' },
  { label: 'Desechables', value: 'desechables' },
  { label: 'Hielo', value: 'hielo' },
  { label: 'Insumos Secos', value: 'insumos_secos' },
  { label: 'Renta', value: 'renta' },
  { label: 'Nómina', value: 'nomina' },
  { label: 'Servicios (luz, agua, gas)', value: 'servicios' },
  { label: 'Gastos Financieros', value: 'gastos_financieros' },
  { label: 'Pago de Deuda', value: 'pago_deuda' },
  { label: 'Mantenimiento', value: 'mantenimiento' },
  { label: 'Gastos Staff', value: 'gastos_staff' },
  { label: 'Gastos Varios', value: 'gastos_varios' }
]

const paymentSourceOptions = [
  { label: 'Efectivo (Caja Chica)', value: 'efectivo_caja_chica' },
  { label: 'Efectivo (Bóveda)', value: 'efectivo_boveda' },
  { label: 'Transferencia (Mercado Pago)', value: 'transferencia_negocio' },
  { label: 'Tarjeta del Negocio', value: 'tarjeta_negocio' },
  { label: 'Tarjeta de Daniel', value: 'tarjeta_daniel' },
  { label: 'Tarjeta de Raúl', value: 'tarjeta_raul' }
]

const requiresReimbursement = computed(() => {
  return form.payment_source === 'tarjeta_daniel' || form.payment_source === 'tarjeta_raul'
})

const getCostTypeLabel = (category: string) => {
  const cogsCategories = ['cerveza', 'cerveza_barril', 'vinos_licores', 'refrescos_jugos', 'alimentos', 'desechables', 'hielo', 'insumos_secos']
  const fixedCategories = ['renta', 'nomina', 'servicios', 'gastos_financieros', 'pago_deuda']
  
  if (cogsCategories.includes(category)) return 'COGS'
  if (fixedCategories.includes(category)) return 'Fijo'
  return 'Variable'
}

const getAffectedAccount = (source: string) => {
  const accounts: Record<string, string> = {
    efectivo_caja_chica: 'Caja Chica',
    efectivo_boveda: 'Bóveda',
    transferencia_negocio: 'Mercado Pago',
    tarjeta_negocio: 'Tarjeta del Negocio',
    tarjeta_daniel: 'Ninguna (reembolso)',
    tarjeta_raul: 'Ninguna (reembolso)'
  }
  return accounts[source] || '-'
}

const onSubmit = async () => {
  loading.value = true
  try {
    await api.post('/expenses', form)
    toast.add({
      title: 'Éxito',
      description: 'Gasto registrado correctamente',
      color: 'green'
    })
    router.push('/expenses')
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.data?.message || 'No se pudo guardar el gasto',
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
  }).format(value || 0)
}

// Set today's date by default
onMounted(() => {
  form.expense_date = new Date().toISOString().split('T')[0]
})
</script>
