<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()
const api = useApi()
const router = useRouter()
const toast = useToast()

const loading = ref(false)

const schema = z.object({
  expense_date: z.string().min(1, 'La fecha es requerida'),
  amount: z.number().positive('El monto debe ser mayor a 0'),
  description: z.string().min(3, 'La descripción debe tener al menos 3 caracteres'),
  category: z.string().min(1, 'Selecciona una categoría'),
  payment_source: z.string().min(1, 'Selecciona una fuente de pago'),
  provider: z.string().optional(),
  receipt_photo_url: z.string().optional()
})

type Schema = z.output<typeof schema>

const state = reactive({
  expense_date: new Date().toISOString().split('T')[0],
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
  return state.payment_source === 'tarjeta_daniel' || state.payment_source === 'tarjeta_raul'
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

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true

  try {
    await api.post('/expenses', event.data)
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
</script>

<template>
  <UDashboardPanel id="expense-new">
    <template #header>
      <UDashboardNavbar title="Nuevo Gasto">
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
              <UIcon name="i-lucide-bell" class="size-5" />
            </UButton>
          </UTooltip>
        </template>
      </UDashboardNavbar>

      <UDashboardToolbar>
        <template #left>
          <UButton
            to="/expenses"
            variant="ghost"
            icon="i-lucide-arrow-left"
          >
            Volver
          </UButton>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <UCard>
        <template #header>
          <h3 class="text-lg font-semibold">Datos del Gasto</h3>
          <p class="text-sm text-gray-500 mt-1">Registra un gasto del negocio</p>
        </template>

        <UForm :schema="schema" :state="state" @submit="onSubmit" class="space-y-6">
          <div class="grid md:grid-cols-2 gap-6">
            <!-- Fecha del gasto -->
            <UFormGroup label="Fecha del gasto" name="expense_date" required>
              <UInput
                v-model="state.expense_date"
                type="date"
                size="lg"
              />
            </UFormGroup>

            <!-- Monto -->
            <UFormGroup label="Monto" name="amount" required>
              <UInput
                v-model.number="state.amount"
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
            <UFormGroup label="Categoría" name="category" required>
              <USelect
                v-model="state.category"
                :options="categoryOptions"
                size="lg"
              />
            </UFormGroup>

            <!-- Fuente de pago -->
            <UFormGroup label="Fuente de pago" name="payment_source" required>
              <USelect
                v-model="state.payment_source"
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
                v-model="state.provider"
                placeholder="Central"
                size="lg"
              />
            </UFormGroup>

            <!-- URL de foto de ticket -->
            <UFormGroup label="URL de foto del ticket (opcional)" name="receipt_photo_url">
              <UInput
                v-model="state.receipt_photo_url"
                type="url"
                placeholder="https://..."
                size="lg"
              />
            </UFormGroup>
          </div>

          <!-- Descripción -->
          <UFormGroup label="Descripción" name="description" required>
            <UTextarea
              v-model="state.description"
              rows="3"
              placeholder="Cerveza corona 24 botellas"
            />
          </UFormGroup>

          <!-- Alerta si requiere reembolso -->
          <UAlert
            v-if="requiresReimbursement"
            color="amber"
            icon="i-lucide-alert-circle"
            title="Este gasto requiere reembolso"
            description="Se ha pagado con una tarjeta personal. Deberás crear un reembolso después."
          />

          <!-- Resumen -->
          <UCard class="bg-blue-50 dark:bg-blue-950">
            <template #header>
              <h4 class="font-semibold">Resumen del gasto</h4>
            </template>

            <div class="grid md:grid-cols-3 gap-4">
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Monto</p>
                <p class="text-2xl font-bold text-red-600">${{ formatCurrency(state.amount) }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Tipo de costo</p>
                <p class="text-2xl font-bold">{{ getCostTypeLabel(state.category) }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Cuenta afectada</p>
                <p class="text-2xl font-bold">{{ getAffectedAccount(state.payment_source) }}</p>
              </div>
            </div>
          </UCard>

          <!-- Botones -->
          <div class="flex gap-4">
            <UButton
              type="submit"
              size="lg"
              :loading="loading"
              :disabled="loading"
            >
              Guardar Gasto
            </UButton>
            <UButton
              to="/expenses"
              color="neutral"
              variant="outline"
              size="lg"
            >
              Cancelar
            </UButton>
          </div>
        </UForm>
      </UCard>
    </template>
  </UDashboardPanel>
</template>
