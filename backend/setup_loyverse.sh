#!/bin/bash
set -e

echo "🚀 Configurando Loyverse..."
echo ""

# 1. Verificar que .env existe
if [ ! -f .env ]; then
  echo "⚠️  Archivo .env no encontrado"
  echo "   Creando desde .env.example..."
  cp .env.example .env
  echo ""
  echo "⚠️  IMPORTANTE: Edita .env y agrega tu LOYVERSE_API_TOKEN"
  echo "   Ubicación: backend/.env"
  echo "   Luego vuelve a correr este script"
  exit 1
fi

# 2. Verificar que el token está configurado
if ! grep -q "LOYVERSE_API_TOKEN=.*[a-zA-Z0-9]" .env; then
  echo "❌ LOYVERSE_API_TOKEN no está configurado en .env"
  echo "   Edita backend/.env y agrega tu token de Loyverse"
  echo "   Ejemplo: LOYVERSE_API_TOKEN=fMYgxHEYtcyT8cvtvgi1Za5DRs4vArSyvydlnd9f"
  exit 1
fi

echo "✅ Archivo .env configurado"
echo ""

# 3. Levantar PostgreSQL
echo "📦 Levantando PostgreSQL..."
docker compose up -d

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
for i in {1..30}; do
  if pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✅ PostgreSQL está listo"
    break
  fi

  if [ $i -eq 30 ]; then
    echo "❌ PostgreSQL no respondió después de 30 segundos"
    echo "   Verifica con: docker compose logs"
    exit 1
  fi

  sleep 1
done

echo ""

# 4. Crear base de datos si no existe
echo "🗄️  Creando base de datos..."
bin/rails db:create 2>/dev/null || echo "   Base de datos ya existe"

# 5. Correr migraciones
echo "📋 Corriendo migraciones..."
bin/rails db:migrate

echo ""

# 6. Probar conexión con Loyverse
echo "🔌 Probando conexión con Loyverse API..."
bin/rails loyverse:test_connection

echo ""
echo "✅ ¡Configuración completa!"
echo ""
echo "📝 Próximos pasos:"
echo "   - Sincronizar payment types: bin/rails loyverse:sync_payment_types"
echo "   - Sincronizar receipts: bin/rails loyverse:sync_receipts[2024-11-01,2024-11-18]"
echo "   - Sincronización completa: bin/rails loyverse:full_sync"
