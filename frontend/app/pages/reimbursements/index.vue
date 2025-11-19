<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { isNotificationsSlideoverOpen } = useDashboard()
const api = useApi()
const toast = useToast()

const loadingPending = ref(true)
const loadingHistory = ref(true)
const submitting = ref(false)
const pendingReimbursements = ref<any>(null)
const reimbursements = ref<any[]>([])
const accountOptions = ref<any[]>([])
const showReimbursementModal = ref(false)
const selectedPerson = ref('')

const schema = z.object({
  reimbursement_date: z.string().min(1, 'La fecha es requerida'),
  from_account_id: z.number().positive('Selecciona una cuenta'),
  notes: z.string().optional()
})

type Schema = z.output<typeof schema>

const reimbursementForm = reactive({
  reimbursement_date: new Date().toISOString().split('T')[0],
  to_user_id: null as number | null,
  from_account_id: null as number | null,
  amount: 0,
  expense_ids: [] as number[],
  notes: ''
})

const columns = [{
  key: 'reimbursement_date',
  label: 'Fecha',
  sortable: true
}, {
  key: 'to_user',
  label: 'Para'
}, {
  key: 'amount',
  label: 'Monto'
}, {
  key: 'from_account',
  label: 'Cuenta'
}, {
  key: 'notes',
  label: 'Notas'
}]

const loadPendingReimbursements = async () => {
  loadingPending.value = true
  try {
    const data: any = await api.get('/expenses/pending_reimbursement')
    pendingReimbursements.value = data.pending_reimbursements
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar los reembolsos pendientes',
      color: 'red'
    })
  } finally {
    loadingPending.value = false
  }
}

const loadReimbursements = async () => {
  loadingHistory.value = true
  try {
    const data: any = await api.get('/reimbursements')
    reimbursements.value = data.reimbursements || []
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: 'No se pudieron cargar los reembolsos',
      color: 'red'
    })
  } finally {
    loadingHistory.value = false
  }
}

const loadAccounts = async () => {
  try {
    const data: any = await api.get('/accounts')
    accountOptions.value = (data.accounts || []).map((acc: any) => ({
      label: `${acc.name} ($${formatCurrency(acc.current_balance)})`,
      value: acc.id
    }))
  } catch (error) {
    // Silent error
  }
}

const startReimbursement = (person: string) => {
  selectedPerson.value = person.charAt(0).toUpperCase() + person.slice(1)

  const expenses = pendingReimbursements.value[person].expenses
  const total = pendingReimbursements.value[person].total_amount

  reimbursementForm.expense_ids = expenses.map((e: any) => e.id)
  reimbursementForm.amount = total
  reimbursementForm.to_user_id = expenses[0].user_id
  reimbursementForm.reimbursement_date = new Date().toISOString().split('T')[0]

  showReimbursementModal.value = true
}

const submitReimbursement = async (event: FormSubmitEvent<Schema>) => {
  submitting.value = true
  try {
    await api.post('/reimbursements', {
      ...event.data,
      to_user_id: reimbursementForm.to_user_id,
      amount: reimbursementForm.amount,
      expense_ids: reimbursementForm.expense_ids
    })
    toast.add({
      title: 'Éxito',
      description: 'Reembolso creado correctamente',
      color: 'green'
    })
    showReimbursementModal.value = false
    loadPendingReimbursements()
    loadReimbursements()
  } catch (error: any) {
    toast.add({
      title: 'Error',
      description: error.data?.message || 'No se pudo crear el reembolso',
      color: 'red'
    })
  } finally {
    submitting.value = false
  }
}

const formatCurrency = (value: number) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const getCategoryLabel = (category: string) => {
  const labels: Record<string, string> = {
    cerveza: 'Cerveza',
    alimentos: 'Alimentos',
    hielo: 'Hielo'
  }
  return labels[category] || category
}

onMounted(() => {
  loadPendingReimbursements()
  loadReimbursements()
  loadAccounts()
})
</script>

<template>
  <UDashboardPanel id="reimbursements">
    <template #header>
      <UDashboardNavbar title="Reembolsos">
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
          <p class="text-sm text-gray-500 dark:text-gray-400">
            Gestión de reembolsos por gastos con tarjetas personales
          </p>
        </template>
      </UDashboardToolbar>
    </template>

    <template #body>
      <div class="space-y-8">
        <!-- Gastos pendientes de reembolso -->
        <div>
          <h2 class="text-lg font-semibold mb-4">Gastos Pendientes de Reembolso</h2>

          <div v-if="loadingPending" class="grid md:grid-cols-2 gap-4">
            <USkeleton class="h-48" v-for="i in 2" :key="i" />
          </div>

          <div v-else class="grid md:grid-cols-2 gap-4">
            <!-- Daniel -->
            <UCard>
              <template #header>
                <div class="flex items-center justify-between">
                  <h3 class="font-semibold text-lg">Daniel</h3>
                  <UBadge
                    v-if="pendingReimbursements?.daniel?.total_amount > 0"
                    color="amber"
                    size="lg"
                  >
                    ${{ formatCurrency(pendingReimbursements.daniel.total_amount) }}
                  </UBadge>
                  <UBadge v-else color="green">Al corriente</UBadge>
                </div>
              </template>

              <div v-if="pendingReimbursements?.daniel?.expenses?.length > 0" class="space-y-3">
                <div
                  v-for="expense in pendingReimbursements.daniel.expenses"
                  :key="expense.id"
                  class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg text-sm"
                >
                  <div class="flex justify-between items-start mb-1">
                    <span class="font-medium">{{ expense.description }}</span>
                    <span class="font-bold">${{ formatCurrency(expense.amount) }}</span>
                  </div>
                  <div class="text-gray-600 dark:text-gray-400 text-xs">
                    {{ formatDate(expense.expense_date) }} · {{ getCategoryLabel(expense.category) }}
                  </div>
                </div>

                <UButton
                  @click="startReimbursement('daniel')"
                  block
                  color="amber"
                >
                  Crear Reembolso
                </UButton>
              </div>
              <div v-else class="text-center py-8 text-gray-500">
                No hay gastos pendientes
              </div>
            </UCard>

            <!-- Raúl -->
            <UCard>
              <template #header>
                <div class="flex items-center justify-between">
                  <h3 class="font-semibold text-lg">Raúl</h3>
                  <UBadge
                    v-if="pendingReimbursements?.raul?.total_amount > 0"
                    color="amber"
                    size="lg"
                  >
                    ${{ formatCurrency(pendingReimbursements.raul.total_amount) }}
                  </UBadge>
                  <UBadge v-else color="green">Al corriente</UBadge>
                </div>
              </template>

              <div v-if="pendingReimbursements?.raul?.expenses?.length > 0" class="space-y-3">
                <div
                  v-for="expense in pendingReimbursements.raul.expenses"
                  :key="expense.id"
                  class="p-3 bg-gray-50 dark:bg-gray-900 rounded-lg text-sm"
                >
                  <div class="flex justify-between items-start mb-1">
                    <span class="font-medium">{{ expense.description }}</span>
                    <span class="font-bold">${{ formatCurrency(expense.amount) }}</span>
                  </div>
                  <div class="text-gray-600 dark:text-gray-400 text-xs">
                    {{ formatDate(expense.expense_date) }} · {{ getCategoryLabel(expense.category) }}
                  </div>
                </div>

                <UButton
                  @click="startReimbursement('raul')"
                  block
                  color="amber"
                >
                  Crear Reembolso
                </UButton>
              </div>
              <div v-else class="text-center py-8 text-gray-500">
                No hay gastos pendientes
              </div>
            </UCard>
          </div>
        </div>

        <!-- Historial de reembolsos -->
        <div>
          <h2 class="text-lg font-semibold mb-4">Historial de Reembolsos</h2>

          <UCard>
            <UTable
              v-if="!loadingHistory && reimbursements.length > 0"
              :rows="reimbursements"
              :columns="columns"
            >
              <template #reimbursement_date-data="{ row }">
                {{ formatDate(row.reimbursement_date) }}
              </template>

              <template #to_user-data="{ row }">
                <UBadge color="blue" variant="subtle">{{ row.to_user?.name || '-' }}</UBadge>
              </template>

              <template #amount-data="{ row }">
                <span class="font-semibold text-green-600">${{ formatCurrency(row.amount) }}</span>
              </template>

              <template #from_account-data="{ row }">
                {{ row.from_account?.name || '-' }}
              </template>
            </UTable>

            <div v-else-if="loadingHistory" class="space-y-4 p-4">
              <USkeleton class="h-12" v-for="i in 3" :key="i" />
            </div>

            <div v-else class="text-center py-12">
              <p class="text-gray-500">No hay reembolsos registrados</p>
            </div>
          </UCard>
        </div>
      </div>
    </template>
  </UDashboardPanel>

  <!-- Modal de crear reembolso -->
  <UModal v-model="showReimbursementModal">
    <UCard>
      <template #header>
        <h3 class="text-lg font-semibold">Crear Reembolso para {{ selectedPerson }}</h3>
      </template>

      <UForm :schema="schema" :state="reimbursementForm" @submit="submitReimbursement" class="space-y-4">
        <UFormGroup label="Fecha del reembolso" name="reimbursement_date" required>
          <UInput v-model="reimbursementForm.reimbursement_date" type="date" />
        </UFormGroup>

        <UFormGroup label="Cuenta de origen" name="from_account_id" required>
          <USelect
            v-model="reimbursementForm.from_account_id"
            :options="accountOptions"
          />
        </UFormGroup>

        <UFormGroup label="Monto total">
          <UInput
            :model-value="formatCurrency(reimbursementForm.amount)"
            disabled
          >
            <template #leading>
              <span class="text-gray-500">$</span>
            </template>
          </UInput>
        </UFormGroup>

        <UFormGroup label="Notas (opcional)" name="notes">
          <UTextarea v-model="reimbursementForm.notes" rows="3" />
        </UFormGroup>

        <div class="flex gap-4">
          <UButton type="submit" :loading="submitting" class="flex-1">
            Crear Reembolso
          </UButton>
          <UButton color="neutral" variant="outline" @click="showReimbursementModal = false">
            Cancelar
          </UButton>
        </div>
      </UForm>
    </UCard>
  </UModal>
</template>
