<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent } from '@nuxt/ui'

definePageMeta({
  layout: false
})

const { login } = useAuth()
const router = useRouter()
const toast = useToast()

const loading = ref(false)

const schema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres')
})

type Schema = z.output<typeof schema>

const state = reactive({
  email: '',
  password: ''
})

async function onSubmit(event: FormSubmitEvent<Schema>) {
  loading.value = true

  try {
    await login(event.data.email, event.data.password)
    toast.add({
      title: '¡Bienvenido!',
      description: 'Has iniciado sesión correctamente',
      color: 'green'
    })
    router.push('/')
  } catch (error: any) {
    toast.add({
      title: 'Error de autenticación',
      description: error.data?.message || 'Email o contraseña incorrectos',
      color: 'red'
    })
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-green-50 to-green-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full">
      <!-- Logo y título -->
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-green-600 dark:text-green-500 mb-2">
          🍺 Balconcito ERP
        </h1>
        <p class="text-gray-600 dark:text-gray-400">
          Sistema de Administración Centralizado
        </p>
      </div>

      <!-- Card de login -->
      <UCard class="shadow-xl">
        <template #header>
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white text-center">
            Iniciar Sesión
          </h2>
        </template>

        <UForm :schema="schema" :state="state" @submit="onSubmit" class="space-y-4">
          <UFormGroup label="Email" name="email" required>
            <UInput
              v-model="state.email"
              type="email"
              placeholder="daniel@balconcito.com"
              size="lg"
              icon="i-lucide-mail"
            />
          </UFormGroup>

          <UFormGroup label="Contraseña" name="password" required>
            <UInput
              v-model="state.password"
              type="password"
              placeholder="••••••••"
              size="lg"
              icon="i-lucide-lock"
            />
          </UFormGroup>

          <UButton
            type="submit"
            block
            size="lg"
            :loading="loading"
            :disabled="loading"
          >
            Ingresar
          </UButton>
        </UForm>

        <template #footer>
          <p class="text-sm text-center text-gray-500 dark:text-gray-400">
            Sistema exclusivo para el equipo de Balconcito
          </p>
        </template>
      </UCard>

      <!-- Footer -->
      <div class="mt-8 text-center">
        <p class="text-sm text-gray-500 dark:text-gray-400">
          © {{ new Date().getFullYear() }} Balconcito. Todos los derechos reservados.
        </p>
      </div>
    </div>
  </div>
</template>
