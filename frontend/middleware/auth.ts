export default defineNuxtRouteMiddleware((to, from) => {
  const authStore = useAuthStore()
  
  // Si la ruta requiere autenticación y no hay token
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return navigateTo('/login')
  }
  
  // Si el usuario está autenticado y trata de ir a login
  if (to.path === '/login' && authStore.isAuthenticated) {
    return navigateTo('/')
  }
})
