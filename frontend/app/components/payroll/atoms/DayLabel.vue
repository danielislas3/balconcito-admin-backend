<script setup lang="ts">
export interface DayLabelProps {
  emoji: string
  name: string
  subtitle?: string
}

defineProps<DayLabelProps>()
</script>

<template>
  <div class="flex items-center gap-4 min-w-0">
    <div class="text-3xl flex-shrink-0">{{ emoji }}</div>
    <div class="min-w-0 flex-1">
      <div class="font-semibold text-gray-900 dark:text-white truncate">{{ name }}</div>
      <div v-if="subtitle" class="text-sm text-gray-600 dark:text-gray-400 truncate">
        {{ subtitle }}
      </div>
    </div>
  </div>
</template>
