<script setup lang="ts">
import { Time } from '@internationalized/date'
import type { Week, WeekSchedule } from '~/stores/payroll'
import { usePayrollStore } from '~/stores/payroll'

export interface ScheduleTableProps {
  week: Week
  employeeName: string
}

const props = defineProps<ScheduleTableProps>()
const payrollStore = usePayrollStore()
const toast = useToast()

// Función para convertir string (hora, minuto) a Time object
const stringToTime = (hour: string, minute: string): Time | null => {
  if (!hour || !minute) return null
  const h = parseInt(hour)
  const m = parseInt(minute)
  if (isNaN(h) || isNaN(m)) return null
  return new Time(h, m, 0)
}

// Función para obtener el tiempo de entrada de un día
const getEntryTime = (dayKey: string): Time | null => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  return stringToTime(schedule.entryHour, schedule.entryMinute)
}

// Función para establecer el tiempo de entrada de un día
const setEntryTime = (dayKey: string, value: Time | null) => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  if (value) {
    schedule.entryHour = value.hour.toString().padStart(2, '0')
    schedule.entryMinute = value.minute.toString().padStart(2, '0')
  } else {
    schedule.entryHour = ''
    schedule.entryMinute = ''
  }
  payrollStore.calculateDay(dayKey as keyof WeekSchedule)
}

// Función para obtener el tiempo de salida de un día
const getExitTime = (dayKey: string): Time | null => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  return stringToTime(schedule.exitHour, schedule.exitMinute)
}

// Función para establecer el tiempo de salida de un día
const setExitTime = (dayKey: string, value: Time | null) => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  if (value) {
    schedule.exitHour = value.hour.toString().padStart(2, '0')
    schedule.exitMinute = value.minute.toString().padStart(2, '0')
  } else {
    schedule.exitHour = ''
    schedule.exitMinute = ''
  }
  payrollStore.calculateDay(dayKey as keyof WeekSchedule)
}

// Presets de horarios comunes
const schedulePresets = [
  { label: '16:00 - 01:00', entry: { hour: '16', minute: '00' }, exit: { hour: '01', minute: '00' } },
  { label: '10:00 - 19:00', entry: { hour: '10', minute: '00' }, exit: { hour: '19', minute: '00' } },
  { label: '8:00 - 17:00', entry: { hour: '08', minute: '00' }, exit: { hour: '17', minute: '00' } },
  { label: '11:00 - 20:00', entry: { hour: '11', minute: '00' }, exit: { hour: '20', minute: '00' } },
]

const selectedDays = ref<Set<string>>(new Set())
const showCopyDialog = ref(false)
const sourceDayForCopy = ref<string>('')

const showSaveTemplateDialog = ref(false)
const showLoadTemplateDialog = ref(false)
const templateName = ref('')
const templateDescription = ref('')

const formatDate = (dateStr: string) => {
  return payrollStore.formatWeekDisplay(dateStr)
}

// Aplicar preset a un día
const applyPreset = (dayKey: string, preset: typeof schedulePresets[0], showToast = true) => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  schedule.entryHour = preset.entry.hour
  schedule.entryMinute = preset.entry.minute
  schedule.exitHour = preset.exit.hour
  schedule.exitMinute = preset.exit.minute
  payrollStore.calculateDay(dayKey as keyof WeekSchedule)

  if (showToast) {
    toast.add({
      title: 'Horario aplicado',
      description: `${preset.label} aplicado correctamente`,
      color: 'success'
    })
  }
}

// Aplicar preset a todos los días
const applyPresetToAll = (preset: typeof schedulePresets[0]) => {
  payrollStore.days.forEach(day => {
    applyPreset(day.key, preset, false) // No mostrar toast individual
  })

  toast.add({
    title: 'Horarios aplicados',
    description: `${preset.label} aplicado a toda la semana`,
    color: 'success'
  })
}

// Copiar horario de un día
const copyDay = (dayKey: string) => {
  sourceDayForCopy.value = dayKey
  selectedDays.value = new Set()
  showCopyDialog.value = true
}

// Aplicar copia a días seleccionados
const applyCopy = () => {
  if (!sourceDayForCopy.value || selectedDays.value.size === 0) return

  const sourceSchedule = props.week.schedule[sourceDayForCopy.value as keyof WeekSchedule]

  selectedDays.value.forEach(targetDay => {
    const targetSchedule = props.week.schedule[targetDay as keyof WeekSchedule]
    targetSchedule.entryHour = sourceSchedule.entryHour
    targetSchedule.entryMinute = sourceSchedule.entryMinute
    targetSchedule.exitHour = sourceSchedule.exitHour
    targetSchedule.exitMinute = sourceSchedule.exitMinute
    payrollStore.calculateDay(targetDay as keyof WeekSchedule)
  })

  toast.add({
    title: 'Horarios copiados',
    description: `Horario copiado a ${selectedDays.value.size} día(s)`,
    color: 'success'
  })

  showCopyDialog.value = false
  selectedDays.value = new Set()
}

// Limpiar un día
const clearDay = (dayKey: string) => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  schedule.entryHour = ''
  schedule.entryMinute = ''
  schedule.exitHour = ''
  schedule.exitMinute = ''
  payrollStore.calculateDay(dayKey as keyof WeekSchedule)
}

// Toggle selección de día
const toggleDaySelection = (dayKey: string) => {
  if (selectedDays.value.has(dayKey)) {
    selectedDays.value.delete(dayKey)
  } else {
    selectedDays.value.add(dayKey)
  }
}

// Verificar si un día tiene datos
const hasDayData = (dayKey: string) => {
  const schedule = props.week.schedule[dayKey as keyof WeekSchedule]
  return schedule.hoursWorked > 0 || (schedule.entryHour && schedule.exitHour)
}

// Funciones para plantillas
const openSaveTemplateDialog = () => {
  templateName.value = `Plantilla ${new Date().toLocaleDateString()}`
  templateDescription.value = ''
  showSaveTemplateDialog.value = true
}

const saveAsTemplate = () => {
  if (!templateName.value.trim()) {
    toast.add({
      title: 'Error',
      description: 'Por favor ingresa un nombre para la plantilla',
      color: 'error'
    })
    return
  }

  const result = payrollStore.saveWeekAsTemplate(
    props.week.id,
    templateName.value.trim(),
    templateDescription.value.trim() || undefined
  )

  if (result) {
    toast.add({
      title: 'Plantilla guardada',
      description: `"${templateName.value}" se guardó correctamente`,
      color: 'success'
    })
    showSaveTemplateDialog.value = false
  } else {
    toast.add({
      title: 'Error',
      description: 'No se pudo guardar la plantilla',
      color: 'error'
    })
  }
}

const loadTemplate = (templateId: string) => {
  const success = payrollStore.loadTemplateToWeek(templateId, props.week.id)

  if (success) {
    toast.add({
      title: 'Plantilla aplicada',
      description: 'Los horarios se copiaron correctamente',
      color: 'success'
    })
    showLoadTemplateDialog.value = false
  } else {
    toast.add({
      title: 'Error',
      description: 'No se pudo cargar la plantilla',
      color: 'error'
    })
  }
}

const deleteTemplate = (templateId: string) => {
  if (confirm('¿Estás seguro de que quieres eliminar esta plantilla?')) {
    const success = payrollStore.deleteTemplate(templateId)

    if (success) {
      toast.add({
        title: 'Plantilla eliminada',
        description: 'La plantilla se eliminó correctamente',
        color: 'success'
      })
    }
  }
}

// Computed para obtener plantillas del empleado actual
const availableTemplates = computed(() => {
  return payrollStore.weekTemplates.filter(t =>
    t.employeeId === payrollStore.currentEmployeeId
  )
})
</script>

<style scoped>
.day-card {
  transition: all 0.2s ease;
}

.day-card:hover {
  transform: translateY(-1px);
}
</style>

<template>
  <UCard class="bg-white dark:bg-gray-800 shadow-lg border border-emerald-100 dark:border-emerald-900">
    <template #header>
      <div class="space-y-4">
        <!-- Título -->
        <div>
          <div class="flex items-center gap-2 mb-1">
            <UIcon name="i-lucide-calendar-clock" class="size-5 text-emerald-600" />
            <h2 class="text-lg font-semibold">Horarios - {{ employeeName }}</h2>
          </div>
          <p class="text-sm text-gray-500">Semana del {{ formatDate(week.startDate) }}</p>
        </div>

        <div
          class="flex items-center gap-3 p-3 bg-emerald-50 dark:bg-emerald-950/30 rounded-lg border border-emerald-200 dark:border-emerald-800">
          <span
            class="text-xs uppercase tracking-wider font-semibold text-emerald-700 dark:text-emerald-300 whitespace-nowrap">
            Quick Fill
          </span>
          <div class="flex flex-wrap gap-2">
            <button v-for="preset in schedulePresets" :key="preset.label" @click="applyPresetToAll(preset)"
              class="px-3 py-1.5 text-xs font-medium bg-emerald-600 hover:bg-emerald-700 text-white rounded-md transition-colors whitespace-nowrap">
              {{ preset.label }}
            </button>
          </div>
        </div>

        <!-- Template Actions -->
        <div class="flex gap-2">
          <UButton label="Cargar Plantilla" icon="i-lucide-folder-open" size="sm" color="primary" variant="outline"
            @click="showLoadTemplateDialog = true" :disabled="availableTemplates.length === 0" />
          <UButton label="Guardar como Plantilla" icon="i-lucide-save" size="sm" color="primary"
            @click="openSaveTemplateDialog" />
        </div>
      </div>
    </template>

    <!-- Day Cards - Compacto y Responsive -->
    <div class="space-y-3">
      <div v-for="day in payrollStore.days" :key="day.key" :class="[
        'day-card p-4 rounded-lg border',
        hasDayData(day.key)
          ? 'bg-emerald-50/50 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-800'
          : 'bg-white dark:bg-gray-800/50 border-gray-200 dark:border-gray-700 hover:border-emerald-200 dark:hover:border-emerald-700'
      ]">

        <!-- Header: Day + Actions -->
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-3">
            <span class="text-2xl">{{ day.emoji }}</span>
            <div>
              <h3 class="font-semibold text-base text-gray-800 dark:text-gray-100">{{ day.name }}</h3>
              <p class="text-sm text-gray-600 dark:text-gray-400">
                {{ week.schedule[day.key as keyof WeekSchedule].hoursWorked.toFixed(1) }}h trabajadas
              </p>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex items-center gap-2">
            <button @click="copyDay(day.key)"
              class="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded transition-colors" title="Copiar horario">
              <UIcon name="i-lucide-copy" class="size-4 text-gray-600 dark:text-gray-400" />
            </button>
            <button @click="clearDay(day.key)"
              class="p-2 hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition-colors" title="Limpiar día">
              <UIcon name="i-lucide-trash-2" class="size-4 text-red-600 dark:text-red-400" />
            </button>
          </div>
        </div>

        <!-- Quick Presets -->
        <div class="flex flex-wrap gap-2 mb-3">
          <button v-for="preset in schedulePresets" :key="preset.label" @click="applyPreset(day.key, preset)"
            class="px-3 py-1.5 text-xs font-medium bg-white dark:bg-gray-800 hover:bg-emerald-600 hover:text-white border border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 rounded transition-all"
            title="Quick fill">
            {{ preset.label }}
          </button>
        </div>

        <!-- Time Inputs - Responsive Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3">
          <!-- Entry Time -->
          <div>
            <label class="block text-xs font-semibold text-gray-600 dark:text-gray-400 mb-2 uppercase tracking-wide">
              Entrada
            </label>
            <UInputTime :model-value="getEntryTime(day.key)" icon="i-lucide-clock"
              @update:model-value="(value) => setEntryTime(day.key, value)" size="md" />
          </div>

          <!-- Exit Time -->
          <div>
            <label class="block text-xs font-semibold text-gray-600 dark:text-gray-400 mb-2 uppercase tracking-wide">
              Salida
            </label>
            <UInputTime :model-value="getExitTime(day.key)" @update:model-value="(value) => setExitTime(day.key, value)"
              icon="i-lucide-clock" size="md" />
          </div>
        </div>

        <!-- Results - Responsive -->
        <div v-if="hasDayData(day.key)"
          class="flex flex-wrap items-center gap-3 pt-3 border-t border-gray-200 dark:border-gray-700">
          <div
            class="px-3 py-2 bg-violet-50 dark:bg-violet-900/10 rounded-lg border border-violet-200 dark:border-violet-800">
            <div class="text-xs text-violet-600 dark:text-violet-400 font-semibold mb-0.5">Total</div>
            <div class="text-lg font-bold text-violet-600 dark:text-violet-400">
              {{ payrollStore.formatCurrency(week.schedule[day.key as keyof WeekSchedule].dailyPay) }}
            </div>
          </div>

          <div class="flex gap-3 text-sm">
            <div>
              <span class="text-gray-500 dark:text-gray-400">Regular: </span>
              <span class="font-semibold text-emerald-600 dark:text-emerald-400">{{ week.schedule[day.key as keyof
                WeekSchedule].regularHours.toFixed(1) }}h</span>
            </div>
            <div v-if="week.schedule[day.key as keyof WeekSchedule].overtimeHours1 > 0">
              <span class="text-gray-500 dark:text-gray-400">Extra 1.5x: </span>
              <span class="font-semibold text-amber-600 dark:text-amber-400">{{ week.schedule[day.key as keyof
                WeekSchedule].overtimeHours1.toFixed(1) }}h</span>
            </div>
            <div v-if="week.schedule[day.key as keyof WeekSchedule].overtimeHours2 > 0">
              <span class="text-gray-500 dark:text-gray-400">Extra 2x: </span>
              <span class="font-semibold text-red-600 dark:text-red-400">{{ week.schedule[day.key as keyof
                WeekSchedule].overtimeHours2.toFixed(1) }}h</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </UCard>

  <!-- Copy Modal -->
  <UModal v-model:open="showCopyDialog" title="Copiar Horario" description="Selecciona los días destino">
    <template #body>
      <div class="space-y-2">
        <label v-for="day in payrollStore.days" :key="day.key" v-if="day.key !== sourceDayForCopy" :class="[
          'flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all',
          selectedDays.has(day.key)
            ? 'bg-emerald-50 dark:bg-emerald-900/20 border-emerald-500 dark:border-emerald-500'
            : 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700 hover:border-emerald-300'
        ]">
          <input type="checkbox" :checked="selectedDays.has(day.key)" @change="toggleDaySelection(day.key)"
            class="w-4 h-4 text-emerald-600 rounded focus:ring-emerald-500" />
          <span class="text-xl">{{ day.emoji }}</span>
          <span class="font-medium text-gray-800 dark:text-gray-100">{{ day.name }}</span>
        </label>
      </div>
    </template>

    <template #footer>
      <div class="flex justify-end gap-2">
        <UButton label="Cancelar" color="gray" variant="ghost" @click="showCopyDialog = false" />
        <UButton :label="`Copiar a ${selectedDays.size} día(s)`" icon="i-lucide-copy" color="primary" @click="applyCopy"
          :disabled="selectedDays.size === 0" />
      </div>
    </template>
  </UModal>

  <!-- Save Template Modal -->
  <UModal v-model:open="showSaveTemplateDialog" title="Guardar como Plantilla"
    description="Guarda esta semana como plantilla reutilizable">
    <template #body>
      <div class="space-y-4">
        <UFormField label="Nombre de la plantilla" required>
          <UInput v-model="templateName" placeholder="Ej: Semana típica, Horario de verano..." />
        </UFormField>

        <UFormField label="Descripción (opcional)">
          <UTextarea v-model="templateDescription" placeholder="Agrega notas sobre esta plantilla..." rows="3" />
        </UFormField>
      </div>
    </template>

    <template #footer>
      <div class="flex justify-end gap-2">
        <UButton label="Cancelar" color="gray" variant="ghost" @click="showSaveTemplateDialog = false" />
        <UButton label="Guardar Plantilla" icon="i-lucide-save" color="primary" @click="saveAsTemplate" />
      </div>
    </template>
  </UModal>

  <!-- Load Template Modal -->
  <UModal v-model:open="showLoadTemplateDialog" title="Cargar Plantilla"
    description="Selecciona una plantilla para aplicar a esta semana">
    <template #body>
      <div v-if="availableTemplates.length > 0" class="space-y-2">
        <div v-for="template in availableTemplates" :key="template.id"
          class="p-4 rounded-lg border border-gray-200 dark:border-gray-700 hover:border-emerald-300 dark:hover:border-emerald-700 transition-all">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <h4 class="font-semibold text-gray-900 dark:text-gray-100">{{ template.name }}</h4>
              <p v-if="template.description" class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                {{ template.description }}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-500 mt-2">
                Creada el {{ new Date(template.createdAt).toLocaleDateString() }}
              </p>
            </div>
            <div class="flex gap-2 ml-4">
              <UButton icon="i-lucide-check" size="sm" color="primary" @click="loadTemplate(template.id)"
                title="Aplicar plantilla" />
              <UButton icon="i-lucide-trash-2" size="sm" color="error" variant="ghost"
                @click="deleteTemplate(template.id)" title="Eliminar plantilla" />
            </div>
          </div>
        </div>
      </div>
      <div v-else class="text-center py-8 text-gray-500">
        No hay plantillas guardadas aún
      </div>
    </template>

    <template #footer>
      <div class="flex justify-end">
        <UButton label="Cerrar" color="gray" variant="ghost" @click="showLoadTemplateDialog = false" />
      </div>
    </template>
  </UModal>
</template>
