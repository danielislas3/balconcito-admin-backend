import { $fetch, type FetchOptions } from 'ofetch'
import type { ApiError } from '~/utils/errorHandler'
import { handleApiError } from '~/utils/errorHandler'

/**
 * Composable robusto para realizar solicitudes a la API
 *
 * Proporciona un cliente HTTP centralizado con:
 * - Manejo automático de autenticación (Bearer token)
 * - Manejo robusto de errores HTTP (400, 401, 403, 404, 500, etc.)
 * - Timeout de 10 segundos
 * - Soporte para diferentes tipos de contenido (JSON, Blob, PDF, etc.)
 * - Logging en desarrollo
 * - Integración con sistema de errores centralizado
 *
 * @example
 * ```typescript
 * const api = useApi()
 *
 * // GET request
 * const data = await api.get('/employees')
 *
 * // POST request
 * const created = await api.post('/employees', { name: 'John' })
 *
 * // PATCH request
 * const updated = await api.patch('/employees/123', { name: 'Jane' })
 *
 * // DELETE request
 * await api.delete('/employees/123')
 * ```
 */
export const useApi = () => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()
  const router = useRouter()

  /**
   * Maneja diferentes códigos de estado HTTP
   */
  const handleHttpErrors = (response: { status: any; _data: { error_message?: string } }): ApiError => {
    switch (response.status) {
      case 400:
        return {
          status: response.status,
          message: response._data.error_message || 'Solicitud inválida: El servidor no pudo procesar la petición.',
          data: response._data
        }
      case 401:
        // Limpiar autenticación y redirigir a login
        authStore.logout()
        router.push('/login')
        return {
          status: response.status,
          message: 'No autorizado: Tu sesión ha expirado.'
        }
      case 403:
        return {
          status: response.status,
          message: 'Acceso prohibido: No tienes permisos para acceder a este recurso.'
        }
      case 404:
        return {
          status: response.status,
          message: 'No encontrado: El recurso solicitado no existe.'
        }
      case 422:
        return {
          status: response.status,
          message: response._data.error_message || 'Datos inválidos: Verifica la información proporcionada.',
          data: response._data
        }
      case 500:
        return {
          status: response.status,
          message: 'Error del servidor: Ocurrió un problema inesperado. Intenta de nuevo más tarde.'
        }
      default:
        return {
          status: response.status,
          message: `Error inesperado (código: ${response.status}).`,
          data: response._data
        }
    }
  }

  /**
   * Ejecuta una petición HTTP con manejo robusto de errores
   */
  const execute = async <T = any>(
    endpoint: string,
    options: FetchOptions<'json'> & { expectBlob?: boolean; context?: string } = {}
  ): Promise<T> => {
    const { expectBlob, context, ...fetchOptions } = options

    // Construir headers
    const headers: Record<string, string> = {
      ...(authStore.token ? { Authorization: `Bearer ${authStore.token}` } : {}),
      ...(typeof fetchOptions.headers === 'object' && fetchOptions.headers !== null
        ? Object.fromEntries(Object.entries(fetchOptions.headers).map(([key, value]) => [key, String(value)]))
        : {})
    }

    // Si es FormData, remover Content-Type para que el browser lo setee automáticamente
    if (fetchOptions.body instanceof FormData) {
      delete headers['Content-Type']
    }

    // Log en desarrollo
    if (import.meta.env.DEV) {
      console.log(`📡 [useApi] ${fetchOptions.method || 'GET'} ${endpoint}`)
      if (authStore.token) {
        console.log(`🔐 [useApi] Token: ${authStore.token.substring(0, 20)}...`)
      }
    }

    // Timeout de 10 segundos
    const timeout = new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error('Request timed out')), 10000)
    )

    try {
      // Manejo especial para blobs (PDFs, imágenes, etc.)
      if (endpoint.includes('/file_url') || expectBlob) {
        const fetchResponse = (await Promise.race([
          fetch(`${config.public.apiBase}${endpoint}`, {
            method: fetchOptions.method?.toUpperCase() || 'GET',
            headers,
            body: fetchOptions.body as BodyInit
          }),
          timeout
        ])) as Response

        if (!fetchResponse.ok) {
          const errorData = await fetchResponse.text()
          let parsedError
          try {
            parsedError = JSON.parse(errorData)
          } catch {
            parsedError = { error_message: errorData }
          }

          const apiError = handleHttpErrors({
            status: fetchResponse.status,
            _data: parsedError
          })

          handleApiError(apiError, context)
          throw apiError
        }

        const contentType = fetchResponse.headers.get('content-type') || ''

        // Manejar diferentes tipos de contenido
        if (contentType.includes('application/json')) {
          return await fetchResponse.json()
        } else if (
          contentType.includes('application/pdf') ||
          contentType.includes('application/octet-stream') ||
          contentType.startsWith('image/')
        ) {
          return (await fetchResponse.blob()) as T
        } else {
          return (await fetchResponse.text()) as T
        }
      } else {
        // Usar $fetch para peticiones normales
        const response = await Promise.race([
          $fetch<T>(endpoint, {
            baseURL: config.public.apiBase,
            ...fetchOptions,
            headers,
            method: fetchOptions.method?.toUpperCase() || 'GET'
          }),
          timeout
        ])

        if (import.meta.env.DEV) {
          console.log(`✅ [useApi] Success: ${endpoint}`)
        }

        return response as T
      }
    } catch (err: any) {
      // Manejar timeout
      if (err.message === 'Request timed out') {
        const timeoutError: ApiError = {
          status: null,
          message: 'La solicitud tardó demasiado. Por favor intenta de nuevo.'
        }
        handleApiError(timeoutError, context)
        throw timeoutError
      }

      // Manejar errores de fetch
      if (err.response && err.name === 'FetchError') {
        const apiError = handleHttpErrors(err.response)
        handleApiError(apiError, context)
        throw apiError
      }

      // Manejar otros errores
      const genericError: ApiError = {
        status: null,
        message: err.message || 'Error desconocido'
      }
      handleApiError(genericError, context)
      throw genericError
    }
  }

  /**
   * Métodos HTTP convenientes
   */
  return {
    /**
     * Realiza una petición GET
     */
    get: <T = any>(endpoint: string, options: Omit<FetchOptions<'json'>, 'method'> & { context?: string } = {}) =>
      execute<T>(endpoint, { ...options, method: 'GET' }),

    /**
     * Realiza una petición POST
     */
    post: <T = any>(
      endpoint: string,
      body?: any,
      options: Omit<FetchOptions<'json'>, 'method' | 'body'> & { context?: string } = {}
    ) => execute<T>(endpoint, { ...options, method: 'POST', body }),

    /**
     * Realiza una petición PATCH
     */
    patch: <T = any>(
      endpoint: string,
      body?: any,
      options: Omit<FetchOptions<'json'>, 'method' | 'body'> & { context?: string } = {}
    ) => execute<T>(endpoint, { ...options, method: 'PATCH', body }),

    /**
     * Realiza una petición PUT
     */
    put: <T = any>(
      endpoint: string,
      body?: any,
      options: Omit<FetchOptions<'json'>, 'method' | 'body'> & { context?: string } = {}
    ) => execute<T>(endpoint, { ...options, method: 'PUT', body }),

    /**
     * Realiza una petición DELETE
     */
    delete: <T = any>(endpoint: string, options: Omit<FetchOptions<'json'>, 'method'> & { context?: string } = {}) =>
      execute<T>(endpoint, { ...options, method: 'DELETE' })
  }
}
