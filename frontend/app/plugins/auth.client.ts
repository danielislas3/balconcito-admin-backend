export default defineNuxtPlugin(() => {
  const authStore = useAuthStore()
  
  // Inicializar autenticación desde localStorage
  authStore.initializeAuth()
})
