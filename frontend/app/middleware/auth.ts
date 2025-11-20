export default defineNuxtRouteMiddleware((to, from) => {
  // Solo ejecutar en el cliente
  if (process.server) return

  const authStore = useAuthStore()

  // SIEMPRE intentar inicializar desde localStorage en cada navegación
  // Esto asegura que el store esté hidratado incluso si el plugin no se ejecutó primero
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('auth_token')
    const userStr = localStorage.getItem('auth_user')

    // Si hay datos en localStorage pero el store está vacío, hidratar el store
    if (token && userStr && !authStore.token) {
      try {
        const user = JSON.parse(userStr)
        authStore.token = token
        authStore.user = user
        console.log('🔄 [Middleware] Hydrated auth from localStorage')
      } catch (error) {
        console.error('🔄 [Middleware] Error parsing user:', error)
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
      }
    }
  }

  // Si la ruta requiere autenticación y no hay token
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    console.log('🚫 [Middleware] Not authenticated, redirecting to login')
    return navigateTo('/login')
  }

  // Si el usuario está autenticado y trata de ir a login
  if (to.path === '/login' && authStore.isAuthenticated) {
    console.log('✅ [Middleware] Already authenticated, redirecting to home')
    return navigateTo('/')
  }
})
