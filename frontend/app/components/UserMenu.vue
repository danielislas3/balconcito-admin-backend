<script setup lang="ts">
import type { DropdownMenuItem } from '@nuxt/ui'

defineProps<{
  collapsed?: boolean
}>()

const colorMode = useColorMode()
const appConfig = useAppConfig()
const { user: currentUser, logout } = useAuth()

const colors = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
const neutrals = ['slate', 'gray', 'zinc', 'neutral', 'stone']

// Crear avatar con iniciales del nombre
const userAvatar = computed(() => {
  if (!currentUser.value) return null
  const initials = currentUser.value.name.split(' ').map((n: string) => n[0]).join('').toUpperCase()
  return {
    src: undefined, // Podrías agregar URLs de avatar si las tienes
    alt: currentUser.value.name,
    text: initials
  }
})

const user = computed(() => ({
  name: currentUser.value?.name || 'Usuario',
  avatar: userAvatar.value
}))

const items = computed<DropdownMenuItem[][]>(() => ([[{
  type: 'label',
  label: user.value.name,
  avatar: user.value.avatar
}], [{
  label: 'Configuración',
  icon: 'i-lucide-settings',
  to: '/settings'
}], [{
  label: 'Apariencia',
  icon: 'i-lucide-sun-moon',
  children: [{
    label: 'Claro',
    icon: 'i-lucide-sun',
    type: 'checkbox',
    checked: colorMode.value === 'light',
    onSelect(e: Event) {
      e.preventDefault()
      colorMode.preference = 'light'
    }
  }, {
    label: 'Oscuro',
    icon: 'i-lucide-moon',
    type: 'checkbox',
    checked: colorMode.value === 'dark',
    onSelect(e: Event) {
      e.preventDefault()
      colorMode.preference = 'dark'
    }
  }]
}, {
  label: 'Color Principal',
  icon: 'i-lucide-palette',
  children: colors.map(color => ({
    label: color,
    chip: color,
    slot: 'chip',
    checked: appConfig.ui.colors.primary === color,
    type: 'checkbox',
    onSelect: (e: Event) => {
      e.preventDefault()
      appConfig.ui.colors.primary = color
    }
  }))
}], [{
  label: 'Cerrar Sesión',
  icon: 'i-lucide-log-out',
  onSelect: () => {
    logout()
  }
}]]))
</script>

<template>
  <UDropdownMenu
    :items="items"
    :content="{ align: 'center', collisionPadding: 12 }"
    :ui="{ content: collapsed ? 'w-48' : 'w-(--reka-dropdown-menu-trigger-width)' }"
  >
    <UButton
      v-bind="{
        ...user,
        label: collapsed ? undefined : user?.name,
        trailingIcon: collapsed ? undefined : 'i-lucide-chevrons-up-down'
      }"
      color="neutral"
      variant="ghost"
      block
      :square="collapsed"
      class="data-[state=open]:bg-elevated"
      :ui="{
        trailingIcon: 'text-dimmed'
      }"
    />

    <template #chip-leading="{ item }">
      <div class="inline-flex items-center justify-center shrink-0 size-5">
        <span
          class="rounded-full ring ring-bg bg-(--chip-light) dark:bg-(--chip-dark) size-2"
          :style="{
            '--chip-light': `var(--color-${(item as any).chip}-500)`,
            '--chip-dark': `var(--color-${(item as any).chip}-400)`
          }"
        />
      </div>
    </template>
  </UDropdownMenu>
</template>
