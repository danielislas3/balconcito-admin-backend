# 🎨 Balconcito ERP - UI/UX Design System

**Sistema de Diseño Oficial para el Frontend**

---

## 📋 Índice

1. [Filosofía de Diseño](#filosofía-de-diseño)
2. [Sistema de Colores](#sistema-de-colores)
3. [Tipografía](#tipografía)
4. [Espaciado y Grid](#espaciado-y-grid)
5. [Componentes](#componentes)
6. [Patrones de Interacción](#patrones-de-interacción)
7. [Iconografía](#iconografía)
8. [Temas (Light/Dark)](#temas-lightdark)
9. [Guía de Implementación](#guía-de-implementación)

---

## 🎯 Filosofía de Diseño

### Principios Core

**1. Claridad Financiera**
- Los números son protagonistas
- Jerarquía visual clara para métricas clave
- Uso de colores semánticos (verde = positivo, rojo = negativo)

**2. Eficiencia Operativa**
- Interfaces rápidas y directas
- Minimizar clicks para tareas frecuentes
- Feedback visual inmediato

**3. Profesionalismo Accesible**
- Aspecto premium pero no intimidante
- Diseño limpio y moderno
- Usabilidad para usuarios no técnicos

**4. Consistencia Total**
- Mismo look & feel en toda la aplicación
- Patrones repetibles
- Comportamientos predecibles

### Tono Visual

**"Financial Editorial Premium"**
- Refinado y profesional como una app financiera
- Colorido pero equilibrado
- Espacioso pero eficiente
- Moderno pero atemporal

---

## 🎨 Sistema de Colores

### Paleta Principal

```css
/* Variables CSS - Definir en app.vue o nuxt.config */
:root {
  /* Primary - Emerald/Teal (Finanzas, Éxito, Crecimiento) */
  --color-primary-50: #ecfdf5;
  --color-primary-100: #d1fae5;
  --color-primary-200: #a7f3d0;
  --color-primary-300: #6ee7b7;
  --color-primary-400: #34d399;
  --color-primary-500: #10b981;  /* Base */
  --color-primary-600: #059669;  /* Main */
  --color-primary-700: #047857;
  --color-primary-800: #065f46;
  --color-primary-900: #064e3b;

  /* Secondary - Teal (Complemento) */
  --color-secondary-500: #14b8a6;
  --color-secondary-600: #0d9488;
  --color-secondary-700: #0f766e;

  /* Success - Green */
  --color-success-500: #22c55e;
  --color-success-600: #16a34a;

  /* Warning - Amber */
  --color-warning-500: #f59e0b;
  --color-warning-600: #d97706;

  /* Error/Danger - Red */
  --color-error-500: #ef4444;
  --color-error-600: #dc2626;

  /* Info - Blue */
  --color-info-500: #3b82f6;
  --color-info-600: #2563eb;

  /* Neutrals */
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;
}
```

### Uso de Colores por Contexto

| Contexto | Color | Uso |
|----------|-------|-----|
| **Ingresos/Positivo** | Success Green | Ventas, ganancias, métricas positivas |
| **Gastos/Negativo** | Error Red | Costos, pérdidas, alertas |
| **Información** | Info Blue | Datos neutrales, horas trabajadas |
| **Advertencia** | Warning Amber | Alertas moderadas, propinas |
| **Primary Actions** | Emerald | Botones principales, headers |
| **Destacados** | Violet/Purple | Totales, pagos importantes |

### Colores Semánticos para Métricas

```typescript
// Usar en Dashboard y Cards de Métricas
const metricColors = {
  totalHoras: {
    bg: 'from-blue-50 to-indigo-50 dark:from-blue-950 dark:to-indigo-950',
    border: 'border-blue-100 dark:border-blue-900',
    icon: 'text-blue-600 dark:text-blue-400',
    text: 'text-blue-900 dark:text-blue-100'
  },
  turnos: {
    bg: 'from-emerald-50 to-teal-50 dark:from-emerald-950 dark:to-teal-950',
    border: 'border-emerald-100 dark:border-emerald-900',
    icon: 'text-emerald-600 dark:text-emerald-400',
    text: 'text-emerald-900 dark:text-emerald-100'
  },
  horasExtra: {
    bg: 'from-amber-50 to-orange-50 dark:from-amber-950 dark:to-orange-950',
    border: 'border-amber-100 dark:border-amber-900',
    icon: 'text-amber-600 dark:text-amber-400',
    text: 'text-amber-900 dark:text-amber-100'
  },
  pagoTotal: {
    bg: 'from-violet-50 to-purple-50 dark:from-violet-950 dark:to-purple-950',
    border: 'border-violet-100 dark:border-violet-900',
    icon: 'text-violet-600 dark:text-violet-400',
    text: 'text-violet-900 dark:text-violet-100'
  }
}
```

---

## ✍️ Tipografía

### Fuentes del Sistema

**Usar las fuentes del sistema nativo (System UI)**

```css
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
             "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
```

**Ventajas:**
- ✅ Carga instantánea (no requiere descarga)
- ✅ Nativo en cada OS (iOS, Android, Windows, Mac)
- ✅ Excelente legibilidad
- ✅ Accesibilidad optimizada

### Escala Tipográfica

```typescript
// Tailwind CSS Classes
const typography = {
  // Headers
  h1: 'text-3xl md:text-4xl font-bold tracking-tight',
  h2: 'text-2xl md:text-3xl font-bold tracking-tight',
  h3: 'text-xl md:text-2xl font-semibold',
  h4: 'text-lg font-semibold',
  h5: 'text-base font-semibold',

  // Body
  bodyLarge: 'text-lg font-normal',
  body: 'text-base font-normal',
  bodySmall: 'text-sm font-normal',
  caption: 'text-xs font-medium',

  // Numbers (métricas financieras)
  metricHuge: 'text-5xl md:text-6xl font-black tabular-nums',
  metricLarge: 'text-3xl md:text-4xl font-bold tabular-nums',
  metricMedium: 'text-2xl font-bold tabular-nums',
  metricSmall: 'text-xl font-semibold tabular-nums',

  // Labels
  label: 'text-sm font-medium text-gray-700 dark:text-gray-300',
  labelUppercase: 'text-xs font-semibold uppercase tracking-wider'
}
```

### Uso de `tabular-nums`

**IMPORTANTE:** Siempre usar `tabular-nums` en números financieros

```vue
<!-- ✅ Correcto -->
<span class="text-2xl font-bold tabular-nums">$13,258.39</span>

<!-- ❌ Incorrecto - números desalineados -->
<span class="text-2xl font-bold">$13,258.39</span>
```

```css
/* Agregar en CSS global */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}
```

---

## 📐 Espaciado y Grid

### Escala de Espaciado (Tailwind)

```javascript
// Usar múltiplos de 4px (sistema de 8pt grid)
const spacing = {
  xs: '0.5rem',  // 8px   - gap-2
  sm: '0.75rem', // 12px  - gap-3
  md: '1rem',    // 16px  - gap-4
  lg: '1.5rem',  // 24px  - gap-6
  xl: '2rem',    // 32px  - gap-8
  '2xl': '3rem', // 48px  - gap-12
}
```

### Grid Layouts

**Dashboard Grid (métricas)**
```vue
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
  <!-- Metric cards -->
</div>
```

**Form Grid (2 columnas)**
```vue
<div class="grid md:grid-cols-2 gap-4">
  <!-- Form fields -->
</div>
```

**Cards Grid (reportes)**
```vue
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <!-- Employee cards -->
</div>
```

### Contenedor Principal

```vue
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
  <!-- Content -->
</div>
```

---

## 🧩 Componentes

### 1. Cards

**Card Básica**
```vue
<UCard class="bg-white dark:bg-gray-800 shadow-lg hover:shadow-xl transition-shadow duration-300 border border-emerald-100 dark:border-emerald-900">
  <template #header>
    <div class="flex items-center gap-2">
      <UIcon name="i-lucide-icon" class="size-5 text-emerald-600" />
      <h3 class="text-lg font-semibold">Título</h3>
    </div>
  </template>

  <!-- Content -->

  <template #footer>
    <!-- Footer actions -->
  </template>
</UCard>
```

**Metric Card (con gradiente)**
```vue
<div class="group relative bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-950 dark:to-teal-950 rounded-2xl p-6 border-2 border-emerald-100 dark:border-emerald-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
  <!-- Decorative circle -->
  <div class="absolute top-0 right-0 w-32 h-32 bg-emerald-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500"></div>

  <div class="relative">
    <div class="flex items-center justify-between mb-4">
      <div class="p-3 bg-emerald-500/10 rounded-xl group-hover:bg-emerald-500/20 transition-colors">
        <UIcon name="i-lucide-briefcase" class="size-6 text-emerald-600 dark:text-emerald-400" />
      </div>
    </div>
    <div class="text-4xl font-bold text-emerald-900 dark:text-emerald-100 mb-1 tabular-nums">
      42
    </div>
    <div class="text-sm font-medium text-emerald-600 dark:text-emerald-400 uppercase tracking-wider">
      Label
    </div>
  </div>
</div>
```

### 2. Botones

**Primary Button**
```vue
<UButton
  label="Acción Principal"
  icon="i-lucide-icon"
  color="success"
  size="lg"
  @click="handleClick" />
```

**Secondary Button**
```vue
<UButton
  label="Acción Secundaria"
  icon="i-lucide-icon"
  color="neutral"
  variant="soft"
  @click="handleClick" />
```

**Destructive Button**
```vue
<UButton
  label="Eliminar"
  icon="i-lucide-trash-2"
  color="error"
  variant="outline"
  @click="handleDelete" />
```

### 3. Forms

**Form Field con Label**
```vue
<UFormField label="Nombre del Campo" required :error="errorMessage">
  <UInput
    v-model="value"
    placeholder="Ingresa el valor"
    icon="i-lucide-icon" />
</UFormField>
```

**Select con Opciones**
```vue
<UFormField label="Selecciona una opción">
  <USelectMenu
    v-model="selected"
    :options="options"
    placeholder="Elige..."
    value-attribute="value" />
</UFormField>
```

### 4. Modals

**Modal Estándar**
```vue
<UModal
  v-model:open="isOpen"
  title="Título del Modal"
  description="Descripción breve del modal"
  :ui="{ content: 'w-full max-w-md' }">

  <template #body>
    <!-- Modal content -->
  </template>

  <template #footer>
    <div class="flex justify-end gap-3">
      <UButton label="Cancelar" color="neutral" variant="ghost" @click="close" />
      <UButton label="Confirmar" color="success" @click="confirm" />
    </div>
  </template>
</UModal>
```

### 5. Tables

**Tabla de Datos**
```vue
<div class="overflow-x-auto">
  <table class="w-full border-separate border-spacing-0 text-sm">
    <thead>
      <tr class="bg-gray-50 dark:bg-gray-800">
        <th class="px-4 py-3 text-left text-xs font-semibold text-gray-700 dark:text-gray-300 uppercase tracking-wider">
          Columna
        </th>
      </tr>
    </thead>
    <tbody>
      <tr class="hover:bg-emerald-50 dark:hover:bg-emerald-950/20 transition-colors">
        <td class="px-4 py-3 border-b border-gray-200 dark:border-gray-700">
          Dato
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

### 6. Stats/Métricas

**Stat Row (para reportes de empleados)**
```vue
<div class="flex items-center justify-between p-4 bg-blue-50 dark:bg-blue-950/20 rounded-xl hover:bg-blue-100 dark:hover:bg-blue-950/30 transition-colors">
  <div class="flex items-center gap-3">
    <div class="p-2 bg-blue-500/10 rounded-lg">
      <UIcon name="i-lucide-clock" class="size-5 text-blue-600 dark:text-blue-400" />
    </div>
    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Total Horas</span>
  </div>
  <span class="text-xl font-bold text-blue-600 dark:text-blue-400 tabular-nums">
    42.5
  </span>
</div>
```

---

## 🎭 Patrones de Interacción

### Hover Effects

**Cards**
```css
hover:shadow-xl hover:scale-105 transition-all duration-300
```

**Buttons**
```css
hover:scale-105 transition-transform duration-200
```

**Icons en Hover**
```css
group-hover:scale-110 transition-transform duration-300
```

### Loading States

**Skeleton Loader**
```vue
<div class="animate-pulse">
  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4 mb-4"></div>
  <div class="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2"></div>
</div>
```

**Spinner**
```vue
<div class="flex items-center justify-center">
  <UIcon name="i-lucide-loader-2" class="size-8 animate-spin text-emerald-600" />
</div>
```

### Toast Notifications

```typescript
// Success
toast.add({
  title: 'Éxito',
  description: 'Operación completada correctamente',
  color: 'success',
  icon: 'i-lucide-check-circle-2'
})

// Error
toast.add({
  title: 'Error',
  description: 'Algo salió mal',
  color: 'error',
  icon: 'i-lucide-alert-circle'
})

// Warning
toast.add({
  title: 'Advertencia',
  description: 'Revisa esta información',
  color: 'warning',
  icon: 'i-lucide-alert-triangle'
})
```

### Transiciones

**Fade In/Out**
```vue
<Transition
  enter-active-class="transition duration-300 ease-out"
  enter-from-class="opacity-0"
  enter-to-class="opacity-100"
  leave-active-class="transition duration-200 ease-in"
  leave-from-class="opacity-100"
  leave-to-class="opacity-0">
  <div v-if="show">Content</div>
</Transition>
```

**Slide from Right**
```vue
<Transition
  enter-active-class="transition duration-300 ease-out"
  enter-from-class="translate-x-full opacity-0"
  enter-to-class="translate-x-0 opacity-100"
  leave-active-class="transition duration-200 ease-in"
  leave-from-class="translate-x-0 opacity-100"
  leave-to-class="translate-x-full opacity-0">
  <div v-if="show">Content</div>
</Transition>
```

---

## 🎯 Iconografía

### Set de Iconos: Lucide

**Usar exclusivamente iconos de Lucide** (ya incluido en Nuxt UI)

```vue
<UIcon name="i-lucide-icon-name" class="size-5" />
```

### Iconos por Contexto

| Contexto | Icono | Código |
|----------|-------|--------|
| Dashboard | Layout Dashboard | `i-lucide-layout-dashboard` |
| Dinero/Pagos | Banknote | `i-lucide-banknote` |
| Wallet | Wallet | `i-lucide-wallet` |
| Gastos | Shopping Cart | `i-lucide-shopping-cart` |
| Ventas | Receipt | `i-lucide-receipt` |
| Usuarios | User Circle | `i-lucide-user-circle` |
| Empleados | Users | `i-lucide-users` |
| Tiempo/Horas | Clock | `i-lucide-clock` |
| Calendario | Calendar | `i-lucide-calendar` |
| Reportes | Bar Chart | `i-lucide-bar-chart-3` |
| Configuración | Settings | `i-lucide-settings` |
| Exportar | Download | `i-lucide-download` |
| Importar | Upload | `i-lucide-upload` |
| Éxito | Check Circle | `i-lucide-check-circle-2` |
| Error | Alert Circle | `i-lucide-alert-circle` |
| Warning | Alert Triangle | `i-lucide-alert-triangle` |
| Info | Info | `i-lucide-info` |
| Editar | Pencil | `i-lucide-pencil` |
| Eliminar | Trash | `i-lucide-trash-2` |
| Agregar | Plus | `i-lucide-plus` |
| Cerrar | X | `i-lucide-x` |

### Tamaños de Iconos

```typescript
const iconSizes = {
  xs: 'size-3',   // 12px
  sm: 'size-4',   // 16px
  md: 'size-5',   // 20px
  lg: 'size-6',   // 24px
  xl: 'size-8',   // 32px
  '2xl': 'size-12' // 48px
}
```

---

## 🌓 Temas (Light/Dark)

### Implementación Automática

Nuxt UI ya maneja light/dark mode automáticamente. Usar clases de Tailwind:

```vue
<div class="bg-white dark:bg-gray-800 text-gray-900 dark:text-white">
  <!-- Content adapta automáticamente -->
</div>
```

### Preferencias del Usuario

```typescript
// El tema se maneja automáticamente por Nuxt UI
// Se sincroniza con preferencias del sistema

// Para forzar un tema específico:
const colorMode = useColorMode()
colorMode.preference = 'dark' // 'light' | 'dark' | 'system'
```

### Gradientes en Dark Mode

**IMPORTANTE:** Los gradientes necesitan ajustes especiales en dark mode

```vue
<!-- ✅ Correcto - ajusta opacidad en dark -->
<div class="bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-950 dark:to-teal-950">
```

```vue
<!-- ❌ Incorrecto - muy brillante en dark -->
<div class="bg-gradient-to-br from-emerald-50 to-teal-50">
```

---

## 🚀 Guía de Implementación

### 1. Configuración Inicial

**nuxt.config.ts**
```typescript
export default defineNuxtConfig({
  modules: ['@nuxt/ui'],

  ui: {
    icons: ['lucide'] // Habilitar iconos de Lucide
  },

  tailwindcss: {
    config: {
      theme: {
        extend: {
          colors: {
            // Extender colores si es necesario
            primary: colors.emerald
          }
        }
      }
    }
  }
})
```

**app.vue o layouts/default.vue**
```vue
<style>
/* Agregar font-variant-numeric para números */
.tabular-nums {
  font-variant-numeric: tabular-nums;
}

/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}
</style>
```

### 2. Estructura de Página Estándar

```vue
<template>
  <div class="min-h-screen bg-gradient-to-br from-emerald-50 via-white to-teal-50 dark:from-gray-900 dark:via-gray-800 dark:to-emerald-950">

    <!-- Header -->
    <div class="bg-gradient-to-r from-emerald-600 via-emerald-700 to-teal-700 shadow-2xl shadow-emerald-900/30 sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-6 lg:px-8">
        <div class="flex items-center justify-between h-20">
          <!-- Header content -->
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Page content -->
    </div>

  </div>
</template>
```

### 3. Checklist de Nuevas Páginas

- [ ] Usar contenedor `max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8`
- [ ] Aplicar clases dark mode a todos los elementos
- [ ] Usar `tabular-nums` en todos los números
- [ ] Icons de Lucide exclusivamente
- [ ] Hover effects en cards y botones
- [ ] Transitions suaves (duration-200 o duration-300)
- [ ] Responsive con `md:` y `lg:` breakpoints
- [ ] Colors semánticos (success, error, warning)
- [ ] Loading states y skeletons
- [ ] Toast notifications para acciones

### 4. Cambiar Colores del Tema

**Para cambiar de Emerald/Teal a otro color:**

1. Buscar y reemplazar en todos los archivos:
```
from-emerald-  →  from-blue-
to-teal-       →  to-cyan-
text-emerald-  →  text-blue-
bg-emerald-    →  bg-blue-
border-emerald- → border-blue-
```

2. Actualizar variables en `nuxt.config.ts`:
```typescript
colors: {
  primary: colors.blue // Cambiar a tu color preferido
}
```

3. Probar en light y dark mode

### 5. Variables Globales (Opcional)

Si quieres centralizar los colores aún más, crear un archivo de tema:

**composables/useTheme.ts**
```typescript
export const useTheme = () => {
  const colors = {
    primary: {
      light: 'emerald',
      dark: 'emerald'
    },
    secondary: {
      light: 'teal',
      dark: 'teal'
    }
  }

  return { colors }
}
```

---

## 📝 Ejemplos de Uso

### Dashboard Header

```vue
<div class="bg-gradient-to-r from-emerald-600 via-emerald-700 to-teal-700 shadow-2xl shadow-emerald-900/30">
  <div class="max-w-7xl mx-auto px-6 lg:px-8">
    <div class="flex items-center justify-between h-20">
      <div class="flex items-center gap-4">
        <div class="flex items-center justify-center w-12 h-12 bg-white/10 backdrop-blur-sm rounded-xl">
          <UIcon name="i-lucide-layout-dashboard" class="size-7 text-white" />
        </div>
        <div>
          <h1 class="text-3xl font-bold text-white tracking-tight">Dashboard</h1>
          <p class="text-sm text-emerald-100/80 mt-0.5">Vista general del negocio</p>
        </div>
      </div>
      <UButton label="Nueva Acción" icon="i-lucide-plus" color="white" variant="solid" size="lg" />
    </div>
  </div>
</div>
```

### Metric Card Completa

```vue
<div class="group relative bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-950 dark:to-indigo-950 rounded-2xl p-6 border-2 border-blue-100 dark:border-blue-900 hover:shadow-xl hover:scale-105 transition-all duration-300 cursor-pointer overflow-hidden">
  <div class="absolute top-0 right-0 w-32 h-32 bg-blue-500/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500"></div>
  <div class="relative">
    <div class="flex items-center justify-between mb-4">
      <div class="p-3 bg-blue-500/10 rounded-xl group-hover:bg-blue-500/20 transition-colors">
        <UIcon name="i-lucide-trending-up" class="size-6 text-blue-600 dark:text-blue-400" />
      </div>
    </div>
    <div class="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-1 tabular-nums">
      {{ value }}
    </div>
    <div class="text-sm font-medium text-blue-600 dark:text-blue-400 uppercase tracking-wider">
      {{ label }}
    </div>
  </div>
</div>
```

---

## 🎓 Best Practices

### DO's ✅

1. **Siempre usar `tabular-nums` en números**
2. **Usar iconos de Lucide exclusivamente**
3. **Aplicar dark mode a TODOS los elementos**
4. **Usar colores semánticos (success, error, warning)**
5. **Agregar hover effects a elementos interactivos**
6. **Usar transiciones suaves (200-300ms)**
7. **Mantener consistencia en espaciados (múltiplos de 4)**
8. **Usar grid responsive (`md:grid-cols-2 lg:grid-cols-4`)**
9. **Probar en light y dark mode**
10. **Usar loading states y skeletons**

### DON'Ts ❌

1. **NO usar fuentes custom (solo system fonts)**
2. **NO mezclar iconos de diferentes sets**
3. **NO olvidar clases dark: en elementos**
4. **NO usar colores hard-coded en vez de Tailwind**
5. **NO crear componentes sin hover effects**
6. **NO usar transiciones muy largas (>500ms)**
7. **NO olvidar responsive breakpoints**
8. **NO usar gradientes sin ajustar para dark mode**
9. **NO crear elementos sin estados de loading**
10. **NO repetir código - crear composables**

---

## 📚 Recursos

### Herramientas Útiles

- **Tailwind CSS Docs:** https://tailwindcss.com/docs
- **Nuxt UI Docs:** https://ui.nuxt.com/components
- **Lucide Icons:** https://lucide.dev/icons/
- **Color Palette Generator:** https://uicolors.app/create

### Inspección en DevTools

```javascript
// Ver todas las clases Tailwind aplicadas
document.querySelectorAll('[class]').forEach(el => {
  console.log(el.className)
})
```

---

**Versión:** 1.0
**Fecha:** Diciembre 1, 2024
**Proyecto:** Balconcito ERP

---

> 💡 **Recuerda:** La consistencia es clave. Usa este documento como referencia en cada nueva página o componente que crees.
