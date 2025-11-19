# 🍺 Balconcito ERP - Frontend

Frontend del sistema de administración centralizado para Balconcito, basado en el template oficial de Nuxt UI SaaS con Nuxt 4.2.1 y Nuxt UI 4.2.0.

## 🚀 Stack Tecnológico

- **[Nuxt 4.2.1](https://nuxt.com/)** - Framework Vue.js full-stack
- **[Nuxt UI 4.2.0](https://ui.nuxt.com/)** - Biblioteca de componentes UI (última versión)
- **[Pinia](https://pinia.vuejs.org/)** - State management
- **[Vue 3](https://vuejs.org/)** - Framework JavaScript reactivo
- **[Tailwind CSS](https://tailwindcss.com/)** - Framework de CSS utility-first
- **[VueUse](https://vueuse.org/)** - Colección de utilidades de Vue Composition API
- **[Nuxt Image](https://image.nuxt.com/)** - Optimización de imágenes
- **[Zod](https://zod.dev/)** - Validación de esquemas con TypeScript
- **[Day.js](https://day.js.org/)** - Manipulación de fechas

## 📦 Template Base

Este proyecto está basado en el template oficial de Nuxt UI para aplicaciones SaaS:
```bash
npm create nuxt@latest -- -t github:nuxt-ui-templates/saas
```

## 🛠️ Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env

# Editar .env y configurar la URL del backend
# NUXT_PUBLIC_API_BASE=http://localhost:3000/api/v1
```

## 🏃‍♂️ Desarrollo

```bash
# Iniciar servidor de desarrollo
npm run dev

# El frontend estará disponible en http://localhost:3000
```

## 🏗️ Build

```bash
# Generar build de producción
npm run build

# Preview del build
npm run preview

# Typecheck
npm run typecheck

# Lint
npm run lint
```

## 📁 Estructura del Proyecto

```
frontend/
├── app/                   # Carpeta principal de la aplicación
│   ├── app.vue            # App principal
│   ├── app.config.ts      # Configuración de la app (colores, etc)
│   ├── error.vue          # Página de error
│   ├── pages/             # Páginas de la aplicación
│   │   ├── index.vue      # Landing/Home
│   │   └── login.vue      # Login (adaptado con useAuth)
│   ├── layouts/           # Layouts
│   │   ├── default.vue    # Layout principal
│   │   ├── auth.vue       # Layout para autenticación
│   │   └── dashboard.vue  # Layout para dashboard (A CREAR)
│   ├── components/        # Componentes reutilizables
│   │   ├── AppHeader.vue  # Header principal
│   │   ├── AppFooter.vue  # Footer
│   │   └── AppLogo.vue    # Logo de Balconcito
│   ├── composables/       # Composables de Vue
│   │   ├── useApi.ts      # Cliente HTTP para API ✅
│   │   └── useAuth.ts     # Autenticación ✅
│   ├── stores/            # Pinia stores
│   │   └── auth.ts        # Store de autenticación ✅
│   ├── middleware/        # Middlewares
│   │   └── auth.ts        # Protección de rutas ✅
│   ├── plugins/           # Plugins
│   │   └── auth.client.ts # Inicialización de auth ✅
│   └── types/             # TypeScript types
├── content/               # Nuxt Content (docs, blog)
├── public/                # Archivos estáticos
├── nuxt.config.ts         # Configuración de Nuxt ✅
└── package.json           # Dependencias
```

## ✅ Implementado

- ✅ Template de Nuxt UI SaaS configurado
- ✅ Nuxt 4.2.1 y Nuxt UI 4.2.0
- ✅ Pinia para state management
- ✅ Composables `useApi` y `useAuth`
- ✅ Store de autenticación
- ✅ Middleware de protección de rutas
- ✅ Plugin de inicialización de auth
- ✅ Configuración de API base

## 📋 Por Implementar

Las siguientes páginas y componentes necesitan ser creados basándose en el template:

### Páginas del Dashboard

1. **Dashboard Principal** (`/dashboard`)
   - Métricas en tiempo real
   - Saldos de cuentas
   - Gráficas de ingresos/gastos
   - Alertas de reembolsos pendientes

2. **Cierres de Turno** (`/dashboard/turn-closures`)
   - Lista de cierres con filtros
   - Formulario para nuevo cierre
   - Vista de detalle

3. **Gastos** (`/dashboard/expenses`)
   - Lista de gastos con filtros
   - Formulario para nuevo gasto
   - Categorización automática

4. **Reembolsos** (`/dashboard/reimbursements`)
   - Gastos pendientes por persona
   - Creación de reembolsos
   - Historial

5. **Cuentas** (`/dashboard/accounts`)
   - Visualización de saldos
   - Ajuste manual de balances

### Componentes a Crear

- `DashboardHeader.vue` - Header del dashboard con navegación
- `MetricCard.vue` - Card para mostrar métricas
- `AccountCard.vue` - Card para cuentas
- `ExpenseForm.vue` - Formulario de gastos
- `TurnClosureForm.vue` - Formulario de cierres

## 🎨 Configuración de UI

El proyecto usa Nuxt UI con configuración personalizada. Para personalizar colores y tema:

```ts
// app/app.config.ts
export default defineAppConfig({
  ui: {
    colors: {
      primary: 'green',  // Color principal de Balconcito
      neutral: 'slate'
    }
  }
})
```

## 🔐 Autenticación

El sistema de autenticación está configurado con:

1. **Store de Pinia** (`stores/auth.ts`)
   - Gestión de token JWT
   - Información del usuario
   - Persistencia en localStorage

2. **Composable useAuth** (`composables/useAuth.ts`)
   - Métodos: `login()`, `logout()`, `checkAuth()`
   - Computed properties: `user`, `isAuthenticated`

3. **Middleware** (`middleware/auth.ts`)
   - Protección de rutas privadas
   - Redirección automática

### Uso en páginas

```vue
<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})

const { user, logout } = useAuth()
</script>
```

## 🌐 Conexión con Backend

Configurar la URL del backend en `.env`:

```bash
NUXT_PUBLIC_API_BASE=http://localhost:3000/api/v1
```

### Uso del composable useApi

```vue
<script setup lang="ts">
const api = useApi()

// GET
const data = await api.get('/accounts')

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

## 📖 Componentes de Nuxt UI

El proyecto incluye acceso completo a los componentes de Nuxt UI 4.2.0:

### Formularios
- `UForm` - Formularios con validación Zod
- `UFormGroup` - Grupo de campos
- `UInput`, `UTextarea`, `USelect`, `UCheckbox`, `URadio`

### Datos
- `UTable` - Tablas con sorting y paginación
- `UCard` - Cards con slots personalizables
- `UBadge` - Badges de estado

### Navegación
- `UNavigationMenu` - Menú de navegación
- `UHeader` - Header con responsive
- `UTabs` - Pestañas

### Feedback
- `UToast` - Notificaciones toast
- `UAlert` - Alertas
- `UModal` - Modales
- `UDropdown` - Dropdowns

### Layout
- `UMain` - Contenedor principal
- `UPageCard` - Card para páginas
- `USeparator` - Separadores

[Ver documentación completa de componentes](https://ui.nuxt.com/components)

## 🚀 Deployment

### Vercel (Recomendado)

1. Conectar repositorio en Vercel
2. Configurar variables de entorno
3. Deploy automático

### Otras opciones

- **Netlify**
- **Railway**
- **DigitalOcean App Platform**

## 📝 Próximos Pasos

1. ✅ Configurar el template base con Nuxt UI 4.2.0
2. ✅ Configurar autenticación
3. ⏳ Crear layout de dashboard
4. ⏳ Implementar página de dashboard principal
5. ⏳ Crear páginas de cierres de turno
6. ⏳ Crear páginas de gastos
7. ⏳ Crear páginas de reembolsos
8. ⏳ Crear páginas de cuentas
9. ⏳ Agregar gráficas (Chart.js)
10. ⏳ Testing con Vitest
11. ⏳ Deploy a producción

## 📚 Documentación de Referencia

- [Nuxt 4 Docs](https://nuxt.com/docs)
- [Nuxt UI 4 Docs](https://ui.nuxt.com/)
- [Vue 3 Docs](https://vuejs.org/)
- [Pinia Docs](https://pinia.vuejs.org/)
- [VueUse Docs](https://vueuse.org/)

## 🐛 Troubleshooting

### El frontend no se conecta al backend

1. Verificar que el backend esté corriendo
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
npm install
npm run dev
```

---

**Versión:** 2.0  
**Fecha:** Noviembre 2024  
**Template:** Nuxt UI SaaS  
**Stack:** Nuxt 4.2.1 + Nuxt UI 4.2.0
