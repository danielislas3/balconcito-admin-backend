# 🍺 Balconcito ERP - Frontend

Frontend del sistema de administración centralizado para Balconcito, construido con el template oficial **Nuxt UI Dashboard** usando **Nuxt 4.2.1** y **Nuxt UI 4.2.0**.

## 🚀 Stack Tecnológico

- **[Nuxt 4.2.1](https://nuxt.com/)** - Framework Vue.js full-stack
- **[Nuxt UI 4.2.0](https://ui.nuxt.com/)** - Biblioteca de componentes UI (última versión)
- **[Pinia 3.0](https://pinia.vuejs.org/)** - State management
- **[Vue 3](https://vuejs.org/)** - Framework JavaScript reactivo
- **[VueUse](https://vueuse.org/)** - Utilidades de Vue Composition API
- **[Unovis](https://unovis.dev/)** - Librería de visualización de datos (gráficas)
- **[date-fns](https://date-fns.org/)** - Manipulación de fechas
- **[Zod](https://zod.dev/)** - Validación de esquemas con TypeScript
- **[Day.js](https://day.js.org/)** - Manipulación de fechas ligera

## 📦 Template Base

Este proyecto está basado en el **template oficial de Nuxt UI Dashboard**:
```bash
npx nuxi@latest init frontend -t github:nuxt-ui-templates/dashboard --package-manager pnpm
```

El template incluye:
- ✅ Sidebar colapsible y responsivo con `UDashboardSidebar`
- ✅ Layout completo listo para dashboard
- ✅ Sistema de navegación con `UNavigationMenu`
- ✅ Componentes de usuario (`UserMenu`, `TeamsMenu`)
- ✅ Búsqueda global con `UDashboardSearch`
- ✅ Notificaciones con slideover
- ✅ TypeScript configurado
- ✅ ESLint y Prettier

## 🛠️ Instalación

```bash
# Instalar dependencias con pnpm
pnpm install

# Configurar variables de entorno
cp .env.example .env

# Editar .env y configurar la URL del backend
# NUXT_PUBLIC_API_BASE=http://localhost:3000/api/v1
```

## 🏃‍♂️ Desarrollo

```bash
# Iniciar servidor de desarrollo
pnpm dev

# El frontend estará disponible en http://localhost:3000
```

## 🏗️ Build

```bash
# Generar build de producción
pnpm build

# Preview del build
pnpm preview

# Typecheck
pnpm typecheck

# Lint
pnpm lint
```

## 📁 Estructura del Proyecto

```
frontend/
├── app/                        # Carpeta principal de la aplicación
│   ├── app.vue                 # App principal ✅ Adaptado para Balconcito
│   ├── app.config.ts           # Config de UI (colores verde) ✅
│   ├── error.vue               # Página de error
│   ├── pages/                  # Páginas de la aplicación
│   │   ├── index.vue           # Dashboard principal
│   │   ├── customers.vue       # Ejemplo (a reemplazar)
│   │   ├── inbox.vue           # Ejemplo (a reemplazar)
│   │   └── settings.vue        # Configuración
│   ├── layouts/                # Layouts
│   │   └── default.vue         # Layout principal con sidebar ✅ Adaptado
│   ├── components/             # Componentes reutilizables
│   │   ├── UserMenu.vue        # Menú de usuario (perfil, logout)
│   │   ├── TeamsMenu.vue       # Selector de equipos
│   │   └── NotificationsSlideover.vue # Panel de notificaciones
│   ├── composables/            # Composables de Vue
│   │   ├── useApi.ts           # Cliente HTTP para API ✅ Creado
│   │   ├── useAuth.ts          # Autenticación ✅ Creado
│   │   └── useDashboard.ts     # Utils del template
│   ├── stores/                 # Pinia stores
│   │   └── auth.ts             # Store de autenticación ✅ Creado
│   ├── middleware/             # Middlewares
│   │   └── auth.ts             # Protección de rutas ✅ Creado
│   ├── plugins/                # Plugins
│   │   └── auth.client.ts      # Inicialización de auth ✅ Creado
│   ├── utils/                  # Utilidades
│   └── types/                  # TypeScript types
├── server/                     # API routes (Nitro)
├── public/                     # Archivos estáticos
├── nuxt.config.ts              # Configuración de Nuxt ✅ Configurado
├── package.json                # Dependencias ✅
└── README.md                   # Esta documentación
```

## ✅ Implementado

### 1. **Configuración Base**
- ✅ Template de Nuxt UI Dashboard instalado
- ✅ Nuxt 4.2.1 y Nuxt UI 4.2.0
- ✅ Pinia para state management
- ✅ Gestor de paquetes: **pnpm**
- ✅ TypeScript configurado
- ✅ ESLint para código limpio

### 2. **Sistema de Autenticación Completo**
- ✅ `composables/useApi.ts` - Cliente HTTP con manejo automático de tokens JWT
- ✅ `composables/useAuth.ts` - Métodos de login, logout, checkAuth
- ✅ `stores/auth.ts` - Store de Pinia para gestión de token y usuario
- ✅ `middleware/auth.ts` - Protección de rutas privadas
- ✅ `plugins/auth.client.ts` - Inicialización automática desde localStorage

### 3. **Layout y Navegación**
- ✅ Sidebar con navegación adaptada para Balconcito:
  - Dashboard
  - Cierres de Turno
  - Gastos
  - Reembolsos
  - Cuentas
  - Configuración
- ✅ Sidebar colapsible y responsivo
- ✅ Búsqueda global
- ✅ Menú de usuario con logout

### 4. **Configuración**
- ✅ `nuxt.config.ts` con Pinia y runtimeConfig
- ✅ `.env` para API base
- ✅ `app.vue` adaptado para Balconcito (título, descripción, idioma español)
- ✅ `app.config.ts` con color verde primary

## 📋 Por Implementar

### Páginas a Crear

1. **Dashboard Principal** (`app/pages/index.vue`)
   - Reemplazar el actual con:
   - Métricas en tiempo real (cards)
   - Saldos de cuentas (Mercado Pago, Bóveda, Caja Chica)
   - Gráficas de ingresos/gastos
   - Alertas de reembolsos pendientes

2. **Cierres de Turno** (`app/pages/turn-closures/`)
   - `index.vue` - Lista de cierres con filtros y `UTable`
   - `new.vue` - Formulario para nuevo cierre con `UForm` + Zod
   - `[id].vue` - Vista de detalle del cierre

3. **Gastos** (`app/pages/expenses/`)
   - `index.vue` - Lista de gastos con filtros por categoría, fecha
   - `new.vue` - Formulario con 17 categorías y 6 fuentes de pago
   - `[id].vue` - Vista de detalle del gasto

4. **Reembolsos** (`app/pages/reimbursements/`)
   - `index.vue` - Vista de pendientes por persona (Daniel/Raúl) + historial
   - Modal para crear reembolso

5. **Cuentas** (`app/pages/accounts.vue`)
   - Cards de saldos con badges
   - Modal para ajuste manual de saldos

### Componentes a Crear

- `MetricCard.vue` - Card para métricas del dashboard
- `AccountCard.vue` - Card para cuentas con badge de tipo
- `ExpenseForm.vue` - Formulario reutilizable de gastos
- `TurnClosureForm.vue` - Formulario de cierres de turno
- `ReimbursementModal.vue` - Modal para crear reembolsos
- `StatsChart.vue` - Gráfica usando Unovis

## 🎨 Personalización de UI

El proyecto usa Nuxt UI con el color **verde** como primario (Balconcito).

### Configuración de colores

```ts
// app/app.config.ts
export default defineAppConfig({
  ui: {
    colors: {
      primary: 'green',  // Color principal de Balconcito
      neutral: 'slate'   // Color neutral para fondos
    }
  }
})
```

### Componentes de Nuxt UI disponibles

El template incluye componentes profesionales de Nuxt UI 4.2.0:

#### Dashboard
- `UDashboardGroup` - Contenedor principal del dashboard
- `UDashboardSidebar` - Sidebar con navegación
- `UDashboardSearch` - Búsqueda global
- `UDashboardToolbar` - Toolbar para páginas

#### Formularios
- `UForm` - Formularios con validación Zod
- `UFormField` - Grupo de campos
- `UInput`, `UTextarea`, `USelect`, `UCheckbox`, `URadio`

#### Datos
- `UTable` - Tablas con sorting, paginación y selección
- `UCard` - Cards con slots personalizables
- `UBadge` - Badges de estado
- `UChip` - Chips para tags

#### Navegación
- `UNavigationMenu` - Menú de navegación (usado en sidebar)
- `UTabs` - Pestañas
- `UBreadcrumb` - Migas de pan

#### Feedback
- `UToast` - Notificaciones toast (ya configurado)
- `UAlert` - Alertas
- `UModal` - Modales
- `UDropdown` - Dropdowns
- `USlideover` - Panel deslizable

[Ver documentación completa de Nuxt UI](https://ui.nuxt.com/components)

## 🔐 Sistema de Autenticación

### Store de Pinia (`stores/auth.ts`)

```ts
const authStore = useAuthStore()

// State
authStore.token       // JWT token
authStore.user        // Usuario actual

// Getters
authStore.isAuthenticated  // boolean

// Actions
authStore.setToken(token)
authStore.setUser(user)
authStore.logout()
authStore.initializeAuth() // Carga token desde localStorage
```

### Composable useAuth (`composables/useAuth.ts`)

```ts
const { login, logout, checkAuth, user, isAuthenticated } = useAuth()

// Login
await login('daniel@balconcito.com', 'password123')

// Logout
logout() // Limpia token y redirige a /login

// Check auth
const isValid = await checkAuth() // Valida token con backend

// Reactive data
user.value           // Usuario actual
isAuthenticated.value // boolean
```

### Middleware (`middleware/auth.ts`)

Para proteger rutas:

```vue
<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})
</script>
```

### Composable useApi (`composables/useApi.ts`)

Para hacer llamadas a la API:

```vue
<script setup lang="ts">
const api = useApi()

// GET
const accounts = await api.get('/accounts')

// POST
const result = await api.post('/expenses', {
  amount: 100,
  category: 'cerveza'
})

// PATCH
await api.patch('/accounts/1', { current_balance: 5000 })

// DELETE
await api.delete('/expenses/1')
</script>
```

## 🌐 Conexión con Backend

Configurar la URL del backend en `.env`:

```bash
NUXT_PUBLIC_API_BASE=http://localhost:3000/api/v1
```

El composable `useApi` incluye automáticamente:
- Header `Authorization: Bearer {token}`
- Content-Type: application/json
- Manejo de error 401 (logout automático)

## 📊 Visualización de Datos

El template incluye **Unovis** para gráficas:

```vue
<script setup lang="ts">
import { Line, Area, Axis, XYContainer } from '@unovis/vue'

const data = ref([...])  // Tus datos
</script>

<template>
  <XYContainer :data="data" :height="300">
    <Area :x="(d) => d.date" :y="(d) => d.value" />
    <Line :x="(d) => d.date" :y="(d) => d.value" />
    <Axis type="x" :tick-format="formatDate" />
    <Axis type="y" />
  </XYContainer>
</template>
```

## 🚀 Deployment

### Vercel (Recomendado)

1. Conectar repositorio en Vercel
2. Configurar variable de entorno: `NUXT_PUBLIC_API_BASE`
3. Deploy automático

### Otras opciones

- **Netlify**
- **Railway**
- **DigitalOcean App Platform**

## 🧪 Testing

```bash
# Ejecutar tests (cuando se implementen)
pnpm test

# Coverage
pnpm test:coverage
```

## 📝 Próximos Pasos

1. ✅ Configurar el template base con Nuxt UI 4.2.0
2. ✅ Configurar autenticación completa
3. ✅ Adaptar layout con navegación de Balconcito
4. ⏳ Crear página de login con `UAuthForm`
5. ⏳ Implementar dashboard principal con métricas
6. ⏳ Crear páginas de cierres de turno
7. ⏳ Crear páginas de gastos
8. ⏳ Crear páginas de reembolsos
9. ⏳ Crear página de cuentas
10. ⏳ Agregar gráficas con Unovis
11. ⏳ Testing con Vitest
12. ⏳ Deploy a producción

## 📚 Documentación de Referencia

- [Nuxt 4 Docs](https://nuxt.com/docs)
- [Nuxt UI 4 Docs](https://ui.nuxt.com/)
- [Nuxt UI Dashboard Template](https://github.com/nuxt-ui-templates/dashboard)
- [Vue 3 Docs](https://vuejs.org/)
- [Pinia Docs](https://pinia.vuejs.org/)
- [Unovis Docs](https://unovis.dev/)

## 🐛 Troubleshooting

### El frontend no se conecta al backend

1. Verificar que el backend esté corriendo en `http://localhost:3000`
2. Verificar la URL en `.env`
3. Revisar configuración CORS en el backend

### Error de autenticación

1. Limpiar localStorage: `localStorage.clear()`
2. Hacer logout y login nuevamente
3. Verificar que el token sea válido

### Errores de build

```bash
# Limpiar y reinstalar
rm -rf node_modules .nuxt
pnpm install
pnpm dev
```

### Peer dependency warnings

Los warnings de peer dependencies de magicast son normales y no afectan el funcionamiento.

---

**Versión:** 3.0  
**Fecha:** Noviembre 2024  
**Template:** Nuxt UI Dashboard  
**Stack:** Nuxt 4.2.1 + Nuxt UI 4.2.0  
**Gestor de paquetes:** pnpm
