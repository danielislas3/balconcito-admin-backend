export const useAuth = () => {
  const authStore = useAuthStore()
  const api = useApi()

  const login = async (email: string, password: string) => {
    try {
      const response: any = await api.post('/auth/login', { email, password })
      authStore.setToken(response.token)
      authStore.setUser(response.user)
      return response
    } catch (error) {
      throw error
    }
  }

  const logout = () => {
    authStore.logout()
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
    user: computed(() => authStore.user),
    isAuthenticated: computed(() => authStore.isAuthenticated)
  }
}
