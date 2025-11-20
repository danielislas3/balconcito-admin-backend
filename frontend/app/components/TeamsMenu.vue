<script setup lang="ts">
defineProps<{
  collapsed?: boolean
}>()

const organization = {
  label: 'Balconcito',
  icon: 'i-lucide-beer',
  avatar: {
    text: '🍺',
    alt: 'Balconcito'
  }
}
</script>

<template>
  <div class="flex items-center gap-3 px-3 py-2">
    <UAvatar v-bind="organization.avatar" size="sm" />
    <div v-if="!collapsed" class="flex flex-col min-w-0">
      <p class="text-sm font-semibold text-gray-900 dark:text-white truncate">
        {{ organization.label }}
      </p>
      <p class="text-xs text-gray-500 dark:text-gray-400">
        ERP Sistema de Administración
      </p>
    </div>
  </div>
</template>
