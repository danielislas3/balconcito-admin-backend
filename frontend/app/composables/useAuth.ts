export const useAuth = () => {
  const authStore = useAuthStore()
  const api = useApi()
  const toast = useToast()

  const login = async (email: string, password: string) => {
    try {
      const response: any = await api.post('/auth/login', { email, password })

      // Guardar token y usuario en el store (que los persiste en localStorage)
      authStore.setAuth(response.token, response.user)

      toast.add({
        title: '¡Bienvenido!',
        description: `Hola ${response.user.name}`,
        color: 'green',
        icon: 'i-lucide-check-circle'
      })

      return response
    } catch (error: any) {
      toast.add({
        title: 'Error al iniciar sesión',
        description: error.data?.message || 'Credenciales incorrectas',
        color: 'red',
        icon: 'i-lucide-alert-circle'
      })
      throw error
    }
  }

  const logout = () => {
    authStore.logout()

    toast.add({
      title: 'Sesión cerrada',
      description: 'Has cerrado sesión exitosamente',
      color: 'blue',
      icon: 'i-lucide-log-out'
    })

    navigateTo('/login')
  }

  const checkAuth = async () => {
    if (!authStore.token) {
      return false
    }

    try {
      const user: any = await api.get('/auth/me')
      authStore.setUser(user)
      return true
    } catch (error) {
      authStore.logout()
      return false
    }
  }

  return {
    login,
    logout,
    checkAuth,
    user: computed(() => authStore.currentUser),
    isAuthenticated: computed(() => authStore.isAuthenticated),
    userRole: computed(() => authStore.userRole)
  }
}
