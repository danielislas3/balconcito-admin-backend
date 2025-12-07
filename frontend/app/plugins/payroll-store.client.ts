/**
 * Plugin de inicialización del Payroll Store
 *
 * Este plugin se ejecuta automáticamente al iniciar la aplicación
 * en el lado del cliente (client-only) para cargar los datos
 * desde el backend API.
 *
 * El sufijo .client.ts asegura que solo se ejecute en el navegador.
 */

import { usePayrollStore } from '~/stores/payroll'

export default defineNuxtPlugin(async () => {
  // NO cargar datos automáticamente en el plugin
  // Los datos se cargarán cuando el usuario navegue a /payroll
  // Esto evita errores de autenticación en otras páginas
})
