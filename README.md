# 🍺 Balconcito ERP - Sistema de Administración Centralizado

Sistema ERP completo para gestión financiera y operativa del bar-restaurante Balconcito.

---

## 📚 Documentación

Este proyecto cuenta con documentación completa dividida en 3 documentos principales:

### 1. [📋 BALCONCITO_ERP_SPEC.md](./BALCONCITO_ERP_SPEC.md) - **LEER PRIMERO**
**Especificación Técnica Completa (70+ páginas)**

Este es el documento más importante. Contiene:
- ✅ Contexto completo del negocio
- ✅ Problema actual y solución propuesta
- ✅ Glosario de términos contables (explicados de forma simple)
- ✅ Arquitectura del sistema
- ✅ Modelos de base de datos detallados
- ✅ Todos los endpoints de la API
- ✅ Flujos de trabajo paso a paso
- ✅ Métricas financieras y cálculos
- ✅ Plan de implementación por milestones

**👉 Lee este documento completo antes de empezar a programar.**

---

### 2. [🚀 BALCONCITO_QUICK_START.md](./BALCONCITO_QUICK_START.md)
**Guía Rápida de Implementación con Checklist**

Documento operativo para desarrollo. Incluye:
- ✅ Checklist de Milestone 1 (Backend)
- ✅ Orden de creación de modelos y migraciones
- ✅ Comandos exactos de Rails
- ✅ Seeds a crear
- ✅ Orden de implementación de controllers
- ✅ Testing strategy
- ✅ Deployment checklist
- ✅ Tips para Claude Code

**👉 Usa este documento como tu guía de trabajo día a día.**

---

### 3. [📐 BALCONCITO_DIAGRAMS.md](./BALCONCITO_DIAGRAMS.md)
**Diagramas Visuales en Mermaid**

Representación visual del sistema. Contiene:
- ✅ Diagrama Entidad-Relación (ERD)
- ✅ Diagramas de flujo (cierres, gastos, reembolsos)
- ✅ Arquitectura del sistema
- ✅ Flujo de dinero
- ✅ Cálculo de métricas
- ✅ Mockup del dashboard
- ✅ Roadmap visual

**👉 Usa este documento para entender el sistema visualmente.**

---

## 🎯 Resumen Ejecutivo

### ¿Qué es Balconcito ERP?

Sistema de administración centralizado que reemplaza formularios de Google y Excel para gestionar todas las finanzas y operaciones del bar Balconcito.

### Problema que resuelve

**Actualmente:**
- ❌ Doble registro de gastos (Loyverse + Google Forms)
- ❌ No hay visibilidad en tiempo real de saldos
- ❌ No se pueden calcular métricas de rentabilidad
- ❌ No se trackean reembolsos pendientes
- ❌ Excel engorroso y propenso a errores

**Con el sistema:**
- ✅ Registro único de cierres y gastos
- ✅ Dashboard con métricas en tiempo real
- ✅ Saldos actualizados automáticamente
- ✅ Trackeo de reembolsos
- ✅ Métricas de rentabilidad (Utilidad Neta, Margen, COGS%, etc.)
- ✅ Punto de equilibrio y cash runway
- ✅ Comparativas entre períodos

### Stack Tecnológico

**Backend:**
- Ruby on Rails 7+ (API mode)
- PostgreSQL
- Devise + JWT (autenticación)

**Frontend:**
- Nuxt.js 3
- Nuxt UI
- Chart.js (gráficas)

---

## 🗂️ Estructura del Proyecto

```
balconcito-erp/
├── backend/              # Rails API
│   ├── app/
│   │   ├── models/      # User, Account, TurnClosure, Expense, Reimbursement
│   │   ├── controllers/ # API endpoints
│   │   ├── services/    # MetricsCalculator
│   │   └── ...
│   ├── db/
│   │   ├── migrate/     # Migraciones
│   │   └── seeds.rb     # Datos iniciales
│   └── ...
│
├── frontend/            # Nuxt.js app
│   ├── pages/          # Vistas
│   ├── components/     # Componentes reutilizables
│   ├── composables/    # Lógica compartida
│   └── ...
│
└── docs/               # Esta carpeta
    ├── README.md
    ├── BALCONCITO_ERP_SPEC.md
    ├── BALCONCITO_QUICK_START.md
    └── BALCONCITO_DIAGRAMS.md
```

---

## 🚀 Plan de Implementación

### Milestone 1 - MVP Core (2-3 semanas) 🎯 **ACTUAL**

**Objetivo:** Reemplazar formularios Google y tener dashboard básico.

**Entregables:**
- ✅ API REST completa
- ✅ Autenticación (Daniel y Raúl)
- ✅ CRUD de Cierres de Turno
- ✅ CRUD de Gastos
- ✅ Sistema de Reembolsos
- ✅ Dashboard con métricas principales:
  - Utilidad Neta
  - Margen Neto %
  - COGS %
  - Labor Cost %
  - Punto de Equilibrio
  - Cash Runway
- ✅ Frontend con Nuxt UI
- ✅ Deploy en staging

---

### Milestone 2 - Inteligencia Financiera (2 semanas)

**Objetivo:** Análisis avanzado y automatizaciones.

**Funcionalidades:**
- Dashboard avanzado con comparativas
- Módulo de Deudas
- Comisiones Mercado Pago (automáticas)
- Alertas visuales

---

### Milestone 3 - Proveedores (1-2 semanas)

**Objetivo:** Optimizar compras.

**Funcionalidades:**
- Catálogo de proveedores
- Productos por proveedor con precios
- Comparación de precios
- Reportes de compras

---

### Milestone 4 - Integración Loyverse (2 semanas)

**Objetivo:** Automatizar importación de ventas.

**Funcionalidades:**
- Conexión con API Loyverse
- Importación automática de cierres
- Análisis de productos vendidos
- Conciliación automática

---

### Milestone 5 - RRHH y Nómina (1-2 semanas)

**Objetivo:** Gestión completa de empleados.

**Funcionalidades:**
- CRUD de empleados
- Control de horas trabajadas
- Cálculo automático de nómina
- Integración con módulo de gastos

---

## 📊 Métricas Clave del Sistema

El sistema calcula automáticamente:

### Métricas de Rentabilidad
1. **Utilidad Neta** - ¿Cuánto ganamos?
2. **Margen de Ganancia Neta %** - ¿Qué % de cada peso es ganancia?

### Métricas de Eficiencia
3. **COGS %** - ¿Cuánto cuestan los productos que vendemos?
4. **Labor Cost %** - ¿Cuánto gastamos en personal?

### Métricas de Supervivencia
5. **Punto de Equilibrio** - ¿Cuánto necesitamos vender para no perder?
6. **Cash Runway** - ¿Cuántos días podemos operar sin ingresos?

Ver [BALCONCITO_ERP_SPEC.md](./BALCONCITO_ERP_SPEC.md) sección "Glosario de Términos Contables" para explicaciones detalladas.

---

## 🏗️ Cómo Empezar

### Para Desarrolladores

1. **Lee la documentación completa:**
   ```bash
   # Orden recomendado:
   1. README.md (este archivo)
   2. BALCONCITO_ERP_SPEC.md (especificación completa)
   3. BALCONCITO_QUICK_START.md (guía de implementación)
   4. BALCONCITO_DIAGRAMS.md (referencia visual)
   ```

2. **Setup del backend:**
   ```bash
   rails new balconcito-api --api --database=postgresql
   cd balconcito-api
   # Seguir checklist en BALCONCITO_QUICK_START.md
   ```

3. **Setup del frontend:**
   ```bash
   npx nuxi init balconcito-frontend
   cd balconcito-frontend
   npm install @nuxt/ui
   # Configurar según spec
   ```

### Para Claude Code

Lee **BALCONCITO_QUICK_START.md** y sigue el checklist paso a paso.

Orden recomendado:
1. Setup proyecto Rails
2. Crear modelos y migraciones (en orden especificado)
3. Implementar validations y callbacks
4. Crear controllers básicos
5. Implementar MetricsCalculator
6. Crear endpoints de dashboard
7. Tests
8. Frontend

---

## 🎯 Criterios de Éxito - Milestone 1

El Milestone 1 será exitoso cuando:

- [x] Daniel y Raúl puedan registrar cierres sin usar Google Forms
- [x] Daniel y Raúl puedan registrar gastos sin usar Google Forms
- [x] El dashboard muestre métricas en tiempo real
- [x] Los saldos se actualicen automáticamente
- [x] Se puedan trackear reembolsos pendientes
- [x] La interfaz sea intuitiva (usuarios no técnicos)
- [x] Sistema desplegado 24/7
- [x] Abandono total del Excel

**Métricas:**
- Tiempo para registrar cierre: **De 10 min → 2 min**
- Errores por semana: **De ~3 → 0**
- Dashboard consultado: **Mínimo 1 vez/día**
- Adopción: **100% de registros en sistema**

---

## 🔐 Consideraciones de Seguridad

- ✅ Contraseñas encriptadas (bcrypt)
- ✅ Tokens JWT con expiración
- ✅ HTTPS obligatorio en producción
- ✅ Validación de inputs en backend
- ✅ Protección contra SQL injection
- ✅ Backups diarios de base de datos

---

## 📞 Contacto

**Proyecto:** Balconcito ERP  
**Cliente:** Daniel & Raúl (Co-propietarios)  
**Negocio:** Balconcito - Bar/Restaurante  
**Ubicación:** Mexico City, Mexico

---

## 📝 Notas de Desarrollo

### Principios del Proyecto

1. **Simplicidad primero** - Si hay dos formas, elegir la más simple
2. **Mobile first** - Dashboard usable desde celular
3. **Performance** - Consultas optimizadas, carga rápida
4. **UX** - Menos clics = mejor experiencia
5. **Confiabilidad** - Más confiable que Excel

### Convenciones

- **Backend:** Código en inglés, seguir Ruby Style Guide
- **Frontend:** Composition API, componentes reutilizables
- **Enums:** Valores en español (como los usa Daniel)
- **Decimals:** Siempre `precision: 15, scale: 2`
- **Tests:** Obligatorios para lógica de negocio

### Git Workflow

- `main` - Producción
- `develop` - Desarrollo
- `feature/*` - Features nuevos
- Commits descriptivos (español o inglés)

---

## 🎉 Estado del Proyecto

**Fase Actual:** 📋 **Especificación Completa**

**Próximo Paso:** 🏗️ **Implementación Milestone 1**

---

## 📚 Enlaces Útiles

### Documentación Técnica
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)
- [Nuxt 3 Documentation](https://nuxt.com/)
- [Nuxt UI](https://ui.nuxt.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

### APIs Externas (Futuros Milestones)
- [Loyverse API](https://developer.loyverse.com/docs/)
- [Mercado Pago API](https://www.mercadopago.com.mx/developers)

### Herramientas Recomendadas
- [Railway](https://railway.app/) - Deploy backend
- [Vercel](https://vercel.com/) - Deploy frontend
- [Postman](https://www.postman.com/) - Test API
- [Mermaid Live](https://mermaid.live/) - Ver diagramas

---

## ✨ Agradecimientos

Especificación técnica creada con la colaboración de Claude (Anthropic).

**Versión:** 1.0  
**Fecha:** Noviembre 16, 2024  
**Última actualización:** Noviembre 16, 2024

---

**¿Listo para empezar?** 🚀

Lee **[BALCONCITO_ERP_SPEC.md](./BALCONCITO_ERP_SPEC.md)** para el contexto completo y después sigue **[BALCONCITO_QUICK_START.md](./BALCONCITO_QUICK_START.md)** para la implementación.

¡Manos a la obra! 💪