/**
 * Plugin de inicialización del Payroll Store
 *
 * Este plugin se ejecuta automáticamente al iniciar la aplicación
 * en el lado del cliente (client-only) para cargar los datos
 * almacenados en localStorage.
 *
 * El sufijo .client.ts asegura que solo se ejecute en el navegador,
 * donde localStorage está disponible.
 */

import { usePayrollStore } from '~/stores/payroll'

export default defineNuxtPlugin(() => {
  const payrollStore = usePayrollStore()

  // Cargar datos desde localStorage al iniciar la aplicación
  if (import.meta.client) {
    console.log('[Payroll Plugin] Inicializando store...')
    payrollStore.loadSystemData()
    console.log('[Payroll Plugin] Empleados cargados:', payrollStore.employees.length)
  }
})
