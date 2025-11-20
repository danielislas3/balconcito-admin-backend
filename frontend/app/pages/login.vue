<script setup lang="ts">
import * as z from 'zod'
import type { FormSubmitEvent, AuthFormField } from '@nuxt/ui'

definePageMeta({
  layout: false
})

const { login } = useAuth()
const router = useRouter()

const fields: AuthFormField[] = [{
  name: 'email',
  type: 'email',
  label: 'Email',
  placeholder: 'Ingresa tu email',
  required: true
}, {
  name: 'password',
  label: 'Contraseña',
  type: 'password',
  placeholder: 'Ingresa tu contraseña',
  required: true
}]

const schema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres')
})

type Schema = z.output<typeof schema>

async function onSubmit(event: FormSubmitEvent<Schema>) {
  try {
    await login(event.data.email, event.data.password)
    router.push('/')
  } catch (error: any) {
    // El error ya se maneja en el composable useAuth
  }
}
</script>

<template>
  <div class="min-h-screen from-green-50 to-green-100 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center px-4 sm:px-6 lg:px-8">
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
        <UAuthForm
          :schema="schema"
          :fields="fields"
          title="Iniciar Sesión"
          icon="i-lucide-lock"
          @submit="onSubmit"
        >
          <template #description>
            Ingresa tus credenciales para acceder al sistema
          </template>

          <template #footer>
            <p class="text-sm text-center text-gray-500 dark:text-gray-400">
              Sistema exclusivo para el equipo de Balconcito
            </p>
          </template>
        </UAuthForm>
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
