export const useApi = () => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const apiFetch = async (endpoint: string, options: any = {}) => {
    const token = authStore.token

    const defaultOptions = {
      baseURL: config.public.apiBase,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      ...options
    }

    try {
      const response = await $fetch(endpoint, defaultOptions)
      return response
    } catch (error: any) {
      // Si el error es 401, limpiar el token y redirigir al login
      if (error.response?.status === 401) {
        authStore.logout()
        navigateTo('/login')
      }
      throw error
    }
  }

  return {
    get: (endpoint: string, options = {}) => apiFetch(endpoint, { method: 'GET', ...options }),
    post: (endpoint: string, body: any, options = {}) => apiFetch(endpoint, { method: 'POST', body, ...options }),
    patch: (endpoint: string, body: any, options = {}) => apiFetch(endpoint, { method: 'PATCH', body, ...options }),
    put: (endpoint: string, body: any, options = {}) => apiFetch(endpoint, { method: 'PUT', body, ...options }),
    delete: (endpoint: string, options = {}) => apiFetch(endpoint, { method: 'DELETE', ...options })
  }
}
