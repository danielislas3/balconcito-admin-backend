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
  closure_number: z.number().positive('Debe ser un número positivo'),
  report_date: z.string().min(1, 'La fecha es requerida'),
  closed_by: z.string().min(1, 'Selecciona quién cerró'),
  cash_collected: z.number().min(0, 'Debe ser mayor o igual a 0'),
  transfer_income: z.number().min(0, 'Debe ser mayor o igual a 0'),
  card_income: z.number().min(0, 'Debe ser mayor o igual a 0'),
  theoretical_cash: z.number().min(0, 'Debe ser mayor o igual a 0'),
  payments_withdrawals: z.number().min(0, 'Debe ser mayor o igual a 0'),
  notes: z.string().optional()
})

type Schema = z.output<typeof schema>

const state = reactive({
  closure_number: null as number | null,
  report_date: new Date().toISOString().split('T')[0],
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
  return state.cash_collected + state.transfer_income + state.card_income
})

const digitalIncome = computed(() => {
  return state.transfer_income + state.card_income
})

const finalCash = computed(() => {
  return 1000 + state.cash_collected - state.payments_withdrawals
})

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true

  try {
    await api.post('/turn_closures', event.data)
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
</script>

<template>
  <UDashboardPanel id="turn-closure-new">
    <template #header>
      <UDashboardNavbar title="Nuevo Cierre de Turno">
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
            to="/turn-closures"
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
          <h3 class="text-lg font-semibold">Datos del Cierre</h3>
          <p class="text-sm text-gray-500 mt-1">Registra el cierre de caja del ticket de Loyverse</p>
        </template>

        <UForm :schema="schema" :state="state" @submit="onSubmit" class="space-y-6">
          <div class="grid md:grid-cols-2 gap-6">
            <!-- Número de cierre -->
            <UFormGroup label="Número de cierre de caja" name="closure_number" required>
              <UInput
                v-model.number="state.closure_number"
                type="number"
                placeholder="59"
                size="lg"
              />
              <template #help>
                Del ticket de Loyverse
              </template>
            </UFormGroup>

            <!-- Fecha del reporte -->
            <UFormGroup label="Fecha del reporte" name="report_date" required>
              <UInput
                v-model="state.report_date"
                type="date"
                size="lg"
              />
              <template #help>
                Cuando abrió el turno
              </template>
            </UFormGroup>

            <!-- Cerrado por -->
            <UFormGroup label="Cerrado por" name="closed_by" required>
              <USelect
                v-model="state.closed_by"
                :options="employeeOptions"
                size="lg"
              />
            </UFormGroup>

            <!-- Cobros en efectivo -->
            <UFormGroup label="Cobros en efectivo" name="cash_collected" required>
              <UInput
                v-model.number="state.cash_collected"
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
            <UFormGroup label="Ingresos por transferencia (brutos)" name="transfer_income" required>
              <UInput
                v-model.number="state.transfer_income"
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
            <UFormGroup label="Ingresos por tarjeta (brutos)" name="card_income" required>
              <UInput
                v-model.number="state.card_income"
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
            <UFormGroup label="Efectivo teórico" name="theoretical_cash" required>
              <UInput
                v-model.number="state.theoretical_cash"
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
            <UFormGroup label="Pagos/Salidas" name="payments_withdrawals" required>
              <UInput
                v-model.number="state.payments_withdrawals"
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
              v-model="state.notes"
              rows="3"
              placeholder="Observaciones adicionales..."
            />
          </UFormGroup>

          <!-- Resumen calculado -->
          <UCard class="bg-green-50 dark:bg-green-950">
            <template #header>
              <h4 class="font-semibold">Resumen</h4>
            </template>

            <div class="grid md:grid-cols-3 gap-4">
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Total de ingresos</p>
                <p class="text-2xl font-bold text-green-600">${{ formatCurrency(totalIncome) }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Efectivo final (Caja Chica)</p>
                <p class="text-2xl font-bold">${{ formatCurrency(finalCash) }}</p>
              </div>
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">Ingresos digitales</p>
                <p class="text-2xl font-bold">${{ formatCurrency(digitalIncome) }}</p>
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
              Guardar Cierre
            </UButton>
            <UButton
              to="/turn-closures"
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
