export default defineNuxtPlugin(async () => {
  const authStore = useAuthStore()

  // Inicializar autenticación desde localStorage
  authStore.initializeAuth()

  // Si hay una sesión guardada, opcionalmente verificar que el token siga válido
  // Esto es útil para detectar tokens expirados al recargar la página
  // Descomenta si quieres validar el token en cada recarga:
  /*
  if (authStore.isAuthenticated) {
    const { checkAuth } = useAuth()
    await checkAuth()
  }
  */
})
