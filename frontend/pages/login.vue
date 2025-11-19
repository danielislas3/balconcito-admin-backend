<template>
  <NuxtLayout name="auth">
    <div>
      <h2 class="text-2xl font-bold text-gray-900 mb-6 text-center">Iniciar Sesión</h2>
      
      <UForm :state="form" @submit="onSubmit" class="space-y-4">
        <UFormGroup label="Email" name="email" required>
          <UInput 
            v-model="form.email" 
            type="email" 
            placeholder="daniel@balconcito.com"
            size="lg"
          />
        </UFormGroup>

        <UFormGroup label="Contraseña" name="password" required>
          <UInput 
            v-model="form.password" 
            type="password" 
            placeholder="••••••••"
            size="lg"
          />
        </UFormGroup>

        <UButton 
          type="submit" 
          block 
          size="lg"
          :loading="loading"
        >
          Ingresar
        </UButton>
      </UForm>

      <UAlert
        v-if="error"
        color="red"
        icon="i-heroicons-exclamation-triangle"
        :title="error"
        class="mt-4"
      />
    </div>
  </NuxtLayout>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false
})

const { login } = useAuth()
const router = useRouter()
const toast = useToast()

const loading = ref(false)
const error = ref('')

const form = reactive({
  email: '',
  password: ''
})

const onSubmit = async () => {
  loading.value = true
  error.value = ''

  try {
    await login(form.email, form.password)
    toast.add({
      title: '¡Bienvenido!',
      description: 'Has iniciado sesión correctamente',
      color: 'green'
    })
    router.push('/')
  } catch (err: any) {
    error.value = err.data?.message || 'Error al iniciar sesión. Verifica tus credenciales.'
  } finally {
    loading.value = false
  }
}
</script>
