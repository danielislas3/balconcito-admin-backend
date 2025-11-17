# Docker Setup - Balconcito Admin

Configuración completa de Docker para desarrollo con PostgreSQL.

---

## 🐳 Arquitectura Docker

El proyecto utiliza Docker Compose con los siguientes servicios:

1. **PostgreSQL 16** - Base de datos principal
2. **Rails Backend** - API REST
3. **Redis 7** - Caché y background jobs

---

## 🚀 Quick Start

### 1. Configurar Variables de Entorno

Copia el archivo de ejemplo y configura tus credenciales:

```bash
cp .env.example .env
```

Edita `.env` y configura:
```env
# Loyverse API (REQUERIDO)
LOYVERSE_API_TOKEN=tu_token_aqui
LOYVERSE_STORE_ID=tu_store_id_aqui

# El resto tiene valores por defecto que funcionan
```

### 2. Construir e Iniciar Servicios

```bash
# Construir imágenes
docker-compose build

# Iniciar todos los servicios
docker-compose up
```

**Nota:** El backend se iniciará automáticamente después de:
- ✅ PostgreSQL esté listo (healthcheck)
- ✅ Base de datos creada (`rails db:create`)
- ✅ Migraciones ejecutadas (`rails db:migrate`)
- ✅ Seeds cargados (`rails db:seed`)

### 3. Verificar que Todo Funciona

En otra terminal:

```bash
# Ver logs
docker-compose logs -f backend

# Verificar API
curl http://localhost:3000/api/v1/auth/me
# Debe responder: {"error":"You need to sign in..."}

# Verificar Swagger
open http://localhost:3000/api-docs
```

---

## 🛠️ Comandos Útiles

### Docker Compose

```bash
# Iniciar servicios en background
docker-compose up -d

# Ver logs de un servicio específico
docker-compose logs -f backend
docker-compose logs -f postgres

# Detener servicios
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Eliminar TODO (contenedores + volúmenes)
docker-compose down -v
```

### Rails dentro de Docker

```bash
# Ejecutar comandos Rails
docker-compose exec backend rails console
docker-compose exec backend rails routes
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed

# Ejecutar tests
docker-compose exec backend rspec

# Ejecutar bash
docker-compose exec backend bash
```

### PostgreSQL

```bash
# Conectar a PostgreSQL
docker-compose exec postgres psql -U balconcito -d balconcito_api_development

# Ver tablas
docker-compose exec postgres psql -U balconcito -d balconcito_api_development -c "\dt"

# Backup de base de datos
docker-compose exec postgres pg_dump -U balconcito balconcito_api_development > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U balconcito -d balconcito_api_development < backup.sql
```

---

## 📁 Estructura de Archivos Docker

```
balconcito-admin/
├── docker-compose.yml          # Orquestación de servicios
├── .env.example                # Plantilla de variables de entorno
├── .env                        # Variables de entorno (NO commitear)
├── .dockerignore               # Archivos ignorados en build
└── backend/
    ├── Dockerfile              # Imagen de producción (Kamal)
    ├── Dockerfile.dev          # Imagen de desarrollo
    ├── docker-entrypoint.sh    # Script de inicialización
    └── .dockerignore           # Archivos ignorados del backend
```

---

## 🔧 Configuración Detallada

### docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: balconcito
      POSTGRES_PASSWORD: balconcito_dev_password
      POSTGRES_DB: balconcito_api_development
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U balconcito"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      DATABASE_HOST: postgres
      DATABASE_USERNAME: balconcito
      DATABASE_PASSWORD: balconcito_dev_password
      DATABASE_NAME: balconcito_api_development
      REDIS_URL: redis://redis:6379/0
    volumes:
      - ./backend:/rails        # Hot reload
      - bundle_cache:/usr/local/bundle
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
```

### database.yml (Híbrido)

El archivo `backend/config/database.yml` ahora soporta:

**Con Docker (si `DATABASE_HOST` está definido):**
```yaml
development:
  adapter: postgresql
  host: postgres
  database: balconcito_api_development
  username: balconcito
  password: balconcito_dev_password
```

**Sin Docker (desarrollo local):**
```yaml
development:
  adapter: sqlite3
  database: storage/development.sqlite3
```

Esto permite trabajar con o sin Docker sin cambiar configuración.

---

## 🔄 Flujo de Desarrollo

### Opción A: Con Docker (Recomendado)

```bash
# 1. Iniciar servicios
docker-compose up -d

# 2. Ver logs en tiempo real
docker-compose logs -f backend

# 3. Hacer cambios en el código
# Los cambios se reflejan automáticamente (hot reload)

# 4. Ejecutar migraciones si agregas modelos
docker-compose exec backend rails db:migrate

# 5. Ejecutar tests
docker-compose exec backend rspec

# 6. Acceder a console
docker-compose exec backend rails console
```

### Opción B: Sin Docker (Local)

```bash
# 1. Asegúrate de NO tener DATABASE_HOST en .env
unset DATABASE_HOST

# 2. Instalar gemas
cd backend
bundle install

# 3. Setup base de datos (SQLite)
rails db:create db:migrate db:seed

# 4. Iniciar servidor
rails server

# 5. Usar Swagger
open http://localhost:3000/api-docs
```

---

## 🐛 Troubleshooting

### Error: "connection to server at postgres:5432 failed"

**Causa:** PostgreSQL no está listo aún.

**Solución:**
```bash
# Esperar a que el healthcheck pase
docker-compose logs postgres

# Debe mostrar: "database system is ready to accept connections"
```

### Error: "PG::ConnectionBad"

**Causa:** Credenciales incorrectas o servicio postgres no iniciado.

**Solución:**
```bash
# Verificar que postgres esté corriendo
docker-compose ps

# Reiniciar servicios
docker-compose restart postgres backend
```

### Error: "Migrations are pending"

**Causa:** Nuevas migraciones no ejecutadas.

**Solución:**
```bash
docker-compose exec backend rails db:migrate
```

### Error: "Address already in use (puerto 3000)"

**Causa:** Ya hay un servidor Rails corriendo localmente.

**Solución:**
```bash
# Detener Rails local
pkill -f "rails server"

# O cambiar el puerto en docker-compose.yml
ports:
  - "3001:3000"  # Ahora accede con localhost:3001
```

### Error: "Bundler version mismatch"

**Causa:** Versión de Bundler diferente entre local y Docker.

**Solución:**
```bash
# Limpiar bundle cache
docker-compose down -v
docker-compose build --no-cache backend
docker-compose up
```

### Hot Reload No Funciona

**Causa:** Volúmenes no montados correctamente.

**Solución:**
```bash
# Verificar volúmenes
docker-compose exec backend ls -la /rails/app

# Debe mostrar tus archivos locales

# Si no, reiniciar con volúmenes frescos
docker-compose down -v
docker-compose up
```

---

## 🎯 Casos de Uso

### Ejecutar Rake Tasks

```bash
# Importar datos históricos de finanzas
docker-compose exec backend rails import:finanzas

# Sincronizar receipts de Loyverse
docker-compose exec backend rails loyverse:sync_receipts

# Ver todas las tasks disponibles
docker-compose exec backend rails -T
```

### Agregar Nuevas Gemas

```bash
# 1. Editar Gemfile localmente
echo 'gem "awesome_print"' >> backend/Gemfile

# 2. Reconstruir imagen
docker-compose build backend

# 3. Reiniciar servicio
docker-compose up -d backend

# 4. Verificar
docker-compose exec backend bundle list | grep awesome_print
```

### Ejecutar Seeds con Datos Específicos

```bash
# Limpiar BD y recargar seeds
docker-compose exec backend rails db:reset

# O solo seeds (sin borrar)
docker-compose exec backend rails db:seed
```

### Conectar GUI a PostgreSQL

Puedes usar **TablePlus**, **DBeaver**, **pgAdmin**, etc:

```
Host: localhost
Port: 5432
Database: balconcito_api_development
Username: balconcito
Password: balconcito_dev_password
```

---

## 📊 Volúmenes de Datos

Los datos persisten en volúmenes Docker:

```bash
# Ver volúmenes
docker volume ls | grep balconcito

# Respaldar volumen de postgres
docker run --rm -v balconcito-admin_postgres_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres_backup.tar.gz /data

# Restaurar volumen
docker run --rm -v balconcito-admin_postgres_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/postgres_backup.tar.gz -C /

# Eliminar TODOS los volúmenes (CUIDADO: pierdes los datos)
docker-compose down -v
```

---

## 🚀 Preparar para Producción

Este setup es para **desarrollo**. Para producción:

1. **Usar Dockerfile original** (no `Dockerfile.dev`)
2. **Configurar variables de entorno** seguras:
   ```bash
   RAILS_ENV=production
   DATABASE_PASSWORD=<contraseña segura>
   DEVISE_JWT_SECRET_KEY=<secreto largo>
   RAILS_MASTER_KEY=<de config/master.key>
   ```

3. **Usar Kamal** para deployment:
   ```bash
   cd backend
   kamal setup
   kamal deploy
   ```

4. **O Docker Compose con override** para producción:
   ```bash
   docker-compose -f docker-compose.yml \
                  -f docker-compose.prod.yml up -d
   ```

---

## 📖 Referencias

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Rails Docker Guide](https://guides.rubyonrails.org/development_dependencies_install.html#using-docker)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [Redis Docker Hub](https://hub.docker.com/_/redis)

---

## 💡 Tips

1. **Usar alias para comandos frecuentes:**
   ```bash
   alias dce='docker-compose exec backend'
   alias dcl='docker-compose logs -f backend'
   alias dcr='docker-compose restart backend'

   # Ahora puedes hacer:
   dce rails console
   dce rspec spec/models
   ```

2. **Ver métricas de recursos:**
   ```bash
   docker stats balconcito_backend balconcito_postgres
   ```

3. **Limpiar imágenes viejas:**
   ```bash
   docker system prune -a
   ```

4. **Usar `.env.local` para sobreescribir** (no commitear):
   ```bash
   cp .env .env.local
   # Edita .env.local con tus valores locales
   ```

---

**Última actualización:** 17 de noviembre, 2025
**Versión Docker:** 3.8
