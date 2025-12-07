/**
 * Sistema centralizado de manejo de errores para la aplicación
 *
 * Este módulo proporciona funciones para manejar errores de API de manera consistente
 * en toda la aplicación, incluyendo logging, notificaciones al usuario y preparación
 * para reportes de errores futuros.
 */

export interface ApiError {
  status: number | null
  message: string | null
  data?: any
}

/**
 * Maneja errores de API de manera centralizada
 *
 * @param error - El error capturado
 * @param context - Contexto opcional para logging (ej. "fetchEmployees", "createWeek")
 */
export const handleApiError = (error: ApiError, context?: string) => {
  // 1. Log detallado para desarrollo
  if (import.meta.env.DEV) {
    console.group(`🔴 [API Error]${context ? ` ${context}` : ''}`)
    console.error('Status:', error.status)
    console.error('Message:', error.message)
    if (error.data) {
      console.error('Data:', error.data)
    }
    console.groupEnd()
  }

  // 2. Notificación al usuario mediante toast
  // Solo mostramos toast si no es un 401 (ya que ese redirige a login)
  if (error.status !== 401) {
    const toast = useToast()

    toast.add({
      title: getErrorTitle(error.status),
      description: error.message || 'Ocurrió un error inesperado. Por favor intenta de nuevo.',
      color: 'error'
    })
  }

  // 3. Preparado para futura integración con sistema de reportes
  // Descomenta cuando implementes useErrorReporting
  // if (import.meta.env.PROD && error.status && error.status >= 500) {
  //   const errorReporting = useErrorReporting()
  //   errorReporting.report(error, { context })
  // }
}

/**
 * Obtiene un título apropiado basado en el código de estado HTTP
 */
function getErrorTitle(status: number | null): string {
  if (!status) return 'Error de Conexión'

  if (status >= 500) return 'Error del Servidor'
  if (status >= 400 && status < 500) return 'Error en la Solicitud'

  return 'Error'
}

/**
 * Formatea mensajes de error para mostrar al usuario
 * Útil para transformar errores técnicos en mensajes amigables
 */
export const formatErrorMessage = (error: any): string => {
  if (typeof error === 'string') return error

  if (error.message) return error.message

  if (error._data?.error_message) return error._data.error_message

  return 'Ocurrió un error inesperado'
}

/**
 * Verifica si un error es de tipo ApiError
 */
export const isApiError = (error: any): error is ApiError => {
  return (
    error !== null &&
    typeof error === 'object' &&
    ('status' in error || 'message' in error)
  )
}
