<script setup lang="ts">
export interface InlineStatProps {
  icon: string
  value: string | number
  label?: string
  color: 'blue' | 'emerald' | 'amber' | 'violet' | 'gray'
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<InlineStatProps>(), {
  size: 'md'
})

const colorClasses = {
  blue: {
    bg: 'bg-blue-100 dark:bg-blue-900/30',
    text: 'text-blue-700 dark:text-blue-300',
    icon: 'text-blue-600 dark:text-blue-400'
  },
  emerald: {
    bg: 'bg-emerald-100 dark:bg-emerald-900/30',
    text: 'text-emerald-700 dark:text-emerald-300',
    icon: 'text-emerald-600 dark:text-emerald-400'
  },
  amber: {
    bg: 'bg-amber-100 dark:bg-amber-900/30',
    text: 'text-amber-700 dark:text-amber-300',
    icon: 'text-amber-600 dark:text-amber-400'
  },
  violet: {
    bg: 'bg-violet-100 dark:bg-violet-900/30',
    text: 'text-violet-700 dark:text-violet-300',
    icon: 'text-violet-600 dark:text-violet-400'
  },
  gray: {
    bg: 'bg-gray-100 dark:bg-gray-800',
    text: 'text-gray-700 dark:text-gray-300',
    icon: 'text-gray-600 dark:text-gray-400'
  }
}

const sizeClasses = {
  sm: {
    container: 'px-2 py-1 gap-1',
    icon: 'size-3',
    text: 'text-xs'
  },
  md: {
    container: 'px-3 py-2 gap-2',
    icon: 'size-4',
    text: 'text-sm'
  },
  lg: {
    container: 'px-4 py-2 gap-2',
    icon: 'size-5',
    text: 'text-base'
  }
}
</script>

<template>
  <div :class="[
    'flex items-center rounded-lg font-bold tabular-nums',
    colorClasses[color].bg,
    colorClasses[color].text,
    sizeClasses[size].container
  ]">
    <UIcon :name="icon" :class="[sizeClasses[size].icon, colorClasses[color].icon]" />
    <span v-if="label" :class="['font-medium', sizeClasses[size].text]">
      {{ label }}:
    </span>
    <span :class="sizeClasses[size].text">{{ value }}</span>
  </div>
</template>
