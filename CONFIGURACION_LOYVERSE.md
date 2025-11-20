# Configuración de Loyverse - Guía Rápida

## 🚀 Configuración Simple (Recomendada)

### 1. Obtener tu Token de Loyverse

1. Ve a tu dashboard de Loyverse: https://r.loyverse.com/dashboard/settings/api_tokens
2. Crea un nuevo token o copia el existente
3. El token se verá así: `fMYgxHEYtcyT8cvtvgi1Za5DRs4vArSyvydlnd9f`

### 2. Configurar en tu Aplicación

**Opción A: Usando .env (Local/Development)**

1. Crea un archivo `.env` en `backend/`:
   ```bash
   cd backend
   cp .env.example .env
   ```

2. Edita `.env` y agrega tu token:
   ```bash
   LOYVERSE_API_TOKEN=fMYgxHEYtcyT8cvtvgi1Za5DRs4vArSyvydlnd9f
   ```

3. Reinicia el servidor Rails

**Opción B: Variable de Sistema (Production)**

```bash
export LOYVERSE_API_TOKEN=fMYgxHEYtcyT8cvtvgi1Za5DRs4vArSyvydlnd9f
```

### 3. Instalar Dependencias

```bash
cd backend
bundle install
```

### 4. Verificar que Funciona

```bash
cd backend
bin/rails console

# En la consola de Rails:
Loyverse::Client.new.get_stores
# Debería retornar tus tiendas sin error
```

---

## ✅ ¡Listo!

El token ahora se lee automáticamente de la variable de entorno `LOYVERSE_API_TOKEN`.

No necesitas hacer nada más. Todos los servicios de Loyverse funcionarán automáticamente.

---

## 🔧 Troubleshooting

### Error: "Invalid API token"

1. Verifica que el token esté correctamente copiado (sin espacios)
2. Verifica que la variable esté definida:
   ```bash
   echo $LOYVERSE_API_TOKEN
   ```

### Error: "API token not configured"

1. Asegúrate de haber reiniciado el servidor después de editar `.env`
2. Verifica que `.env` esté en `backend/` (no en la raíz del proyecto)

---

## 📝 Notas

- El token **NO** es un JWT, es un token opaco de Loyverse
- El token se puede cambiar actualizando la variable de entorno
- No necesitas endpoint API para configurarlo (aunque existe uno si lo prefieres usar)
- Prioridad: `ENV['LOYVERSE_API_TOKEN']` > Base de datos

