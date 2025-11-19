# 🍺 Balconcito ERP - Frontend

Frontend del sistema de administración centralizado para Balconcito, construido con Nuxt 4.2.1 y Nuxt UI.

## 🚀 Características

- ✅ **Autenticación** - Sistema de login con JWT
- 📊 **Dashboard** - Métricas en tiempo real del negocio
- 💰 **Cierres de Turno** - Registro de cierres de caja diarios
- 🧾 **Gastos** - Gestión completa de gastos por categoría
- 💳 **Reembolsos** - Trackeo de gastos con tarjetas personales
- 🏦 **Cuentas** - Visualización y ajuste de saldos

## 📋 Requisitos

- Node.js 18+
- npm o pnpm

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

# El frontend estará disponible en http://localhost:3001
```

## 🏗️ Build

```bash
# Generar build de producción
npm run build

# Preview del build
npm run preview
```

## 📁 Estructura del Proyecto

```
frontend/
├── pages/              # Páginas de la aplicación
│   ├── index.vue       # Dashboard
│   ├── login.vue       # Login
│   ├── turn-closures/  # Cierres de turno
│   ├── expenses/       # Gastos
│   ├── reimbursements/ # Reembolsos
│   └── accounts.vue    # Cuentas
├── layouts/            # Layouts
│   ├── default.vue     # Layout principal con navegación
│   └── auth.vue        # Layout para login
├── components/         # Componentes reutilizables
├── composables/        # Composables
│   ├── useApi.ts       # Cliente HTTP para API
│   └── useAuth.ts      # Autenticación
├── stores/             # Pinia stores
│   └── auth.ts         # Store de autenticación
├── middleware/         # Middlewares
│   └── auth.ts         # Protección de rutas
├── plugins/            # Plugins
│   └── auth.client.ts  # Inicialización de auth
└── nuxt.config.ts      # Configuración de Nuxt
```

## 🎨 Tecnologías Utilizadas

- **[Nuxt 4.2.1](https://nuxt.com/)** - Framework Vue.js full-stack
- **[Nuxt UI](https://ui.nuxt.com/)** - Biblioteca de componentes UI
- **[Pinia](https://pinia.vuejs.org/)** - State management
- **[Vue 3](https://vuejs.org/)** - Framework JavaScript reactivo
- **[Tailwind CSS](https://tailwindcss.com/)** - Framework de CSS utility-first

## 📊 Páginas Principales

### Dashboard (`/`)
- Métricas del período seleccionado (día/semana/mes)
- Saldos de cuentas
- Utilidad neta, margen neto, COGS%, punto de equilibrio, cash runway
- Alertas de reembolsos pendientes

### Cierres de Turno (`/turn-closures`)
- Lista de cierres con filtros
- Formulario para registrar nuevos cierres
- Resumen de ingresos por período

### Gastos (`/expenses`)
- Lista de gastos con filtros por categoría, fecha, fuente de pago
- Formulario para registrar gastos
- Identificación automática de gastos que requieren reembolso

### Reembolsos (`/reimbursements`)
- Gastos pendientes de reembolso por persona (Daniel/Raúl)
- Creación de reembolsos
- Historial de reembolsos

### Cuentas (`/accounts`)
- Visualización de saldos de Mercado Pago, Bóveda y Caja Chica
- Ajuste manual de saldos
- Resumen total disponible

## 🔐 Autenticación

El sistema usa JWT (JSON Web Tokens) para autenticación:

1. El usuario hace login en `/login`
2. El backend retorna un token JWT
3. El token se guarda en localStorage
4. Todas las requests a la API incluyen el token en headers
5. El middleware `auth` protege las rutas privadas

### Uso del middleware

```vue
<script setup>
definePageMeta({
  middleware: ['auth'],
  requiresAuth: true
})
</script>
```

## 🌐 API

El frontend se conecta al backend Rails API. Configurar la URL base en `.env`:

```bash
NUXT_PUBLIC_API_BASE=http://localhost:3000/api/v1
```

### Endpoints utilizados

```
# Auth
POST   /auth/login
GET    /auth/me

# Dashboard
GET    /dashboard/summary
GET    /dashboard/profitability
GET    /dashboard/break_even
GET    /dashboard/cash_flow

# Accounts
GET    /accounts
PATCH  /accounts/:id

# Turn Closures
GET    /turn_closures
POST   /turn_closures
DELETE /turn_closures/:id

# Expenses
GET    /expenses
POST   /expenses
DELETE /expenses/:id
GET    /expenses/pending_reimbursement

# Reimbursements
GET    /reimbursements
POST   /reimbursements
```

## 🎯 Convenciones de Código

- **Composition API** con `<script setup>`
- **TypeScript** (opcional pero recomendado)
- Componentes en PascalCase
- Archivos en kebab-case
- Usar composables para lógica reutilizable

## 📝 Notas de Desarrollo

### Formato de moneda

Usar el helper `formatCurrency` para formatear montos:

```js
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}
```

### Formato de fechas

Usar el helper `formatDate`:

```js
const formatDate = (date) => {
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
```

## 🚀 Deploy

### Vercel (Recomendado)

1. Crear cuenta en [Vercel](https://vercel.com)
2. Conectar repositorio de GitHub
3. Configurar variables de entorno
4. Deploy automático en cada push

### Otros proveedores

- **Netlify** - Soporte nativo para Nuxt
- **Railway** - Deploy junto con el backend
- **DigitalOcean App Platform** - Buena opción con control

## 📚 Documentación Adicional

- Ver `/BALCONCITO_ERP_SPEC.md` para especificación completa del sistema
- Ver `/BALCONCITO_QUICK_START.md` para guía de implementación
- Ver `/BALCONCITO_DIAGRAMS.md` para diagramas visuales

## 👥 Usuarios por Defecto

Según la especificación, los usuarios iniciales son:

- **Daniel** (admin)
- **Raúl** (admin)

Consultar con el backend para credenciales de desarrollo.

## 🐛 Troubleshooting

### El frontend no se conecta al backend

1. Verificar que el backend esté corriendo
2. Verificar la URL en `.env`
3. Revisar la consola del navegador para errores CORS

### Error 401 en todas las requests

1. El token JWT expiró - hacer logout y login nuevamente
2. Verificar que el backend esté configurado correctamente

### Los estilos no cargan

```bash
# Limpiar .nuxt y reconstruir
rm -rf .nuxt
npm run dev
```

## 📄 Licencia

Proyecto privado para Balconcito.

---

**Versión:** 1.0  
**Fecha:** Noviembre 2024  
**Stack:** Nuxt 4.2.1 + Nuxt UI
