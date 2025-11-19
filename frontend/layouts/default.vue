<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header con navegación -->
    <header class="bg-white shadow">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 justify-between items-center">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-green-600">🍺 Balconcito ERP</h1>
          </div>
          
          <!-- Navegación principal -->
          <nav class="hidden md:flex space-x-8">
            <NuxtLink 
              to="/" 
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium"
              active-class="text-green-600 bg-green-50"
            >
              Dashboard
            </NuxtLink>
            <NuxtLink 
              to="/turn-closures" 
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium"
              active-class="text-green-600 bg-green-50"
            >
              Cierres
            </NuxtLink>
            <NuxtLink 
              to="/expenses" 
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium"
              active-class="text-green-600 bg-green-50"
            >
              Gastos
            </NuxtLink>
            <NuxtLink 
              to="/reimbursements" 
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium"
              active-class="text-green-600 bg-green-50"
            >
              Reembolsos
            </NuxtLink>
            <NuxtLink 
              to="/accounts" 
              class="text-gray-700 hover:text-green-600 px-3 py-2 rounded-md text-sm font-medium"
              active-class="text-green-600 bg-green-50"
            >
              Cuentas
            </NuxtLink>
          </nav>

          <!-- Usuario y logout -->
          <div class="flex items-center gap-4">
            <UDropdown :items="userMenuItems">
              <UButton 
                color="white" 
                :label="user?.name || 'Usuario'" 
                trailing-icon="i-heroicons-chevron-down-20-solid" 
              />
            </UDropdown>
          </div>
        </div>
      </div>
    </header>

    <!-- Contenido principal -->
    <main class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const { user, logout } = useAuth()

const userMenuItems = [
  [{
    label: user.value?.email || '',
    disabled: true
  }],
  [{
    label: 'Cerrar sesión',
    icon: 'i-heroicons-arrow-right-on-rectangle',
    click: () => logout()
  }]
]
</script>
