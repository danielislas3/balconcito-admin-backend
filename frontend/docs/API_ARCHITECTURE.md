# Arquitectura de API - Guía de Desarrollo

Esta guía documenta la arquitectura de comunicación con el backend y proporciona templates para crear nuevos módulos siguiendo las mejores prácticas.

## 📐 Arquitectura en Capas

El proyecto sigue una arquitectura de 3 capas para la comunicación con el backend:

```
┌─────────────────────────────────────┐
│  Componente/Página Vue             │
│  (UI Layer)                         │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Pinia Store                        │
│  (State Management + Business Logic)│
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  useModuleApi (ej: usePayrollApi)  │
│  (Repository Pattern - Endpoints)   │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  useApi                             │
│  (HTTP Client Base)                 │
└─────────────────────────────────────┘
```

### **Responsabilidades de cada capa:**

1. **`useApi`** (HTTP Client Base)
   - ✅ Manejo de autenticación (Bearer token)
   - ✅ Manejo de errores HTTP (400, 401, 403, 404, 500, etc.)
   - ✅ Timeout de 10 segundos
   - ✅ Logging en desarrollo
   - ✅ Soporte para diferentes content-types (JSON, Blob, PDF, etc.)
   - ❌ **NO conoce endpoints específicos**
   - ❌ **NO conoce tipos de datos del dominio**

2. **`useModuleApi`** (Repository)
   - ✅ Centraliza todos los endpoints del módulo
   - ✅ Transforma datos backend ↔ frontend
   - ✅ Tipos específicos del dominio (PayrollEmployee, DashboardStats, etc.)
   - ✅ Documentación de cada endpoint
   - ❌ **NO maneja estado de la aplicación**
   - ❌ **NO contiene lógica de negocio**

3. **Pinia Store** (State Management)
   - ✅ Manejo de estado reactivo
   - ✅ Lógica de negocio (cálculos, validaciones, transformaciones)
   - ✅ Getters computados
   - ✅ Usa el composable del módulo (`usePayrollApi`, etc.)
   - ❌ **NO conoce endpoints HTTP**
   - ❌ **NO hace peticiones HTTP directamente**

## 🚀 Crear un nuevo módulo

Sigue estos pasos para crear un nuevo módulo (ej: Dashboard):

### **Paso 1: Definir tipos**

Crea `app/types/dashboard.ts`:

```typescript
// Tipos que coinciden con el backend
export interface DashboardStats {
  totalRevenue: number
  totalExpenses: number
  // ... más campos
}

export interface RevenueByMonth {
  month: string
  revenue: number
}
```

### **Paso 2: Crear el composable de API**

Crea `app/composables/useDashboardApi.ts`:

```typescript
import type { DashboardStats } from '~/types/dashboard'

/**
 * API client para el módulo de Dashboard
 *
 * Centraliza todos los endpoints relacionados con estadísticas
 * y datos del dashboard.
 */
export const useDashboardApi = () => {
  const api = useApi()

  /**
   * Obtiene estadísticas generales del dashboard
   * @param period - Período de tiempo (week, month, year)
   * @returns Estadísticas del dashboard
   */
  const fetchStats = async (period: string = 'month'): Promise<DashboardStats> => {
    const response = await api.get<{ stats: DashboardStats }>(
      `/dashboard/stats?period=${period}`,
      { context: 'fetchDashboardStats' }
    )
    return response.stats
  }

  /**
   * Obtiene ingresos por mes
   * @param year - Año a consultar
   * @returns Lista de ingresos por mes
   */
  const fetchRevenueByMonth = async (year: number) => {
    const response = await api.get(
      `/dashboard/revenue_by_month?year=${year}`,
      { context: 'fetchRevenueByMonth' }
    )
    return response.data
  }

  return {
    fetchStats,
    fetchRevenueByMonth
  }
}
```

### **Paso 3: Crear el Pinia Store**

Crea `app/stores/dashboard.ts`:

```typescript
import { defineStore } from 'pinia'
import type { DashboardStats } from '~/types/dashboard'

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    stats: null as DashboardStats | null,
    loading: false,
    error: null as string | null
  }),

  getters: {
    netProfit: (state) => {
      if (!state.stats) return 0
      return state.stats.totalRevenue - state.stats.totalExpenses
    }
  },

  actions: {
    async fetchStats(period: string = 'month') {
      this.loading = true
      this.error = null

      try {
        const api = useDashboardApi()
        this.stats = await api.fetchStats(period)
      } catch (error: any) {
        this.error = error.message || 'Error al cargar estadísticas'
        console.error('Error fetching dashboard stats:', error)
      } finally {
        this.loading = false
      }
    }
  }
})
```

### **Paso 4: Usar en componentes**

```vue
<script setup lang="ts">
import { useDashboardStore } from '~/stores/dashboard'

const dashboardStore = useDashboardStore()

onMounted(async () => {
  await dashboardStore.fetchStats('month')
})
</script>

<template>
  <div>
    <div v-if="dashboardStore.loading">Cargando...</div>
    <div v-else-if="dashboardStore.error">{{ dashboardStore.error }}</div>
    <div v-else>
      <p>Ganancia neta: {{ dashboardStore.netProfit }}</p>
    </div>
  </div>
</template>
```

## 🎯 Mejores prácticas

### **✅ DO (Hacer)**

1. **Usar contexto en las peticiones:**
   ```typescript
   await api.get('/employees', { context: 'fetchEmployees' })
   ```
   Esto mejora el logging y debugging.

2. **Documentar cada función del API client:**
   ```typescript
   /**
    * Obtiene todos los empleados
    * @returns Lista de empleados
    */
   const fetchEmployees = async () => { ... }
   ```

3. **Tipar las respuestas:**
   ```typescript
   const response = await api.get<{ employees: Employee[] }>('/employees')
   ```

4. **Manejar errores en el store:**
   ```typescript
   try {
     this.data = await api.fetchData()
   } catch (error: any) {
     this.error = error.message
     // El toast ya se muestra automáticamente por handleApiError
   }
   ```

5. **Usar getters para datos computados:**
   ```typescript
   getters: {
     totalRevenue: (state) => state.items.reduce((sum, item) => sum + item.price, 0)
   }
   ```

### **❌ DON'T (No hacer)**

1. **NO usar $fetch directamente en el store:**
   ```typescript
   // ❌ MAL
   const data = await $fetch('/api/employees')

   // ✅ BIEN
   const api = usePayrollApi()
   const data = await api.fetchEmployees()
   ```

2. **NO hardcodear endpoints en múltiples lugares:**
   ```typescript
   // ❌ MAL - endpoint duplicado
   await api.get('/payroll_employees')  // en el store
   await api.get('/payroll_employees')  // en otro store

   // ✅ BIEN - centralizado en usePayrollApi
   const payrollApi = usePayrollApi()
   await payrollApi.fetchEmployees()
   ```

3. **NO poner lógica de negocio en el composable de API:**
   ```typescript
   // ❌ MAL - cálculo en el API client
   const fetchEmployeeStats = async () => {
     const employees = await api.get('/employees')
     return employees.reduce((sum, e) => sum + e.salary, 0)  // ❌
   }

   // ✅ BIEN - cálculo en el store/getter
   getters: {
     totalSalaries: (state) => state.employees.reduce((sum, e) => sum + e.salary, 0)
   }
   ```

4. **NO ignorar errores silenciosamente:**
   ```typescript
   // ❌ MAL
   try {
     await api.fetchData()
   } catch (error) {
     // silencio...
   }

   // ✅ BIEN
   try {
     await api.fetchData()
   } catch (error: any) {
     this.error = error.message
     console.error('Error:', error)
   }
   ```

## 🔧 Manejo de errores

El sistema de manejo de errores está centralizado en `utils/errorHandler.ts`:

- **Errores HTTP** (400, 401, 403, etc.) → Se muestran automáticamente con toast
- **401 Unauthorized** → Redirige automáticamente a `/login`
- **Timeout** → Muestra mensaje de timeout
- **Logging** → En desarrollo, se loguea todo en consola

**No necesitas hacer nada especial**, solo captura el error en el store:

```typescript
try {
  this.data = await api.fetchData()
} catch (error: any) {
  // El toast ya se mostró automáticamente
  // Solo necesitas actualizar tu estado local
  this.error = error.message
}
```

## 📝 Ejemplo completo: Módulo de Payroll

Puedes ver el módulo de Payroll como referencia:

- **Tipos:** `app/types/payroll.ts`
- **API Client:** `app/composables/usePayrollApi.ts`
- **Store:** `app/stores/payroll.ts`

## 🤔 ¿Preguntas?

- ¿Cuándo crear un nuevo módulo? → Cuando tengas un grupo coherente de endpoints relacionados
- ¿Puedo tener múltiples stores usando el mismo API client? → Sí, es perfectamente válido
- ¿Puedo mezclar llamadas directas a `useApi` con `useModuleApi`? → No, siempre usa la capa de abstracción

---

**Última actualización:** Enero 2025
