<script setup lang="ts">
export interface StatCardProps {
  icon: string
  value: string | number
  label: string
  description?: string
  badge?: {
    label: string
    color: 'success' | 'warning' | 'error' | 'primary' | 'neutral'
  }
  gradient: {
    from: string
    to: string
  }
  iconColor: string
  textColor: string
}

const props = defineProps<StatCardProps>()
</script>

<template>
  <div :class="[
    'group relative p-6 rounded-2xl border-2 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden',
    `bg-gradient-to-br ${gradient.from} ${gradient.to}`,
    `border-${iconColor.split('-')[0]}-${Number(iconColor.split('-')[1]) + 100}`
  ]">
    <!-- Animated background circle -->
    <div :class="[
      'absolute top-0 right-0 w-32 h-32 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500',
      `bg-${iconColor.split('-')[0]}-500/10`
    ]"></div>

    <!-- Content -->
    <div class="relative">
      <!-- Icon and Badge -->
      <div class="flex items-center justify-between mb-4">
        <div :class="[
          'p-3 rounded-xl transition-colors',
          `bg-${iconColor.split('-')[0]}-500/10 group-hover:bg-${iconColor.split('-')[0]}-500/20`
        ]">
          <UIcon :name="icon" :class="['size-6', iconColor]" />
        </div>
        <UBadge
          v-if="badge"
          :color="badge.color"
          variant="subtle">
          {{ badge.label }}
        </UBadge>
      </div>

      <!-- Value -->
      <div :class="['text-4xl font-bold mb-1 tabular-nums', textColor]">
        {{ value }}
      </div>

      <!-- Label -->
      <div :class="['text-sm font-medium uppercase tracking-wider', iconColor]">
        {{ label }}
      </div>

      <!-- Description -->
      <div v-if="description" class="text-xs text-gray-600 dark:text-gray-400 mt-2">
        {{ description }}
      </div>
    </div>
  </div>
</template>
