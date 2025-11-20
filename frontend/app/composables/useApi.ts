export const useApi = () => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const apiFetch = async (endpoint: string, options: any = {}) => {
    const token = authStore.token

    console.log('🔐 [useApi] Token:', token ? `${token.substring(0, 30)}...` : 'NO TOKEN')
    console.log('📡 [useApi] Request:', endpoint)

    const defaultOptions = {
      baseURL: config.public.apiBase,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {})
      },
      ...options
    }

    console.log('📤 [useApi] Authorization header:', defaultOptions.headers.Authorization ? 'Present' : 'Missing')

    try {
      const response = await $fetch(endpoint, defaultOptions)
      console.log('✅ [useApi] Success:', endpoint)
      return response
    } catch (error: any) {
      console.error('❌ [useApi] Error:', endpoint, 'Status:', error.status || error.response?.status)

      // Si el error es 401, limpiar el token y redirigir al login
      if (error.status === 401 || error.response?.status === 401) {
        console.log('🚪 [useApi] 401 Unauthorized detected, logging out...')
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
