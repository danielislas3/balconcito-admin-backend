#!/bin/bash
# Setup simple de Loyverse - No espera a PostgreSQL, solo corre migraciones

echo "🚀 Setup Simple de Loyverse"
echo "Este script asume que PostgreSQL ya está corriendo"
echo ""

# 1. Verificar .env
if [ ! -f .env ]; then
  echo "⚠️  Creando .env desde .env.example..."
  cp .env.example .env
  echo ""
  echo "⚠️  IMPORTANTE: Edita .env y agrega tu LOYVERSE_API_TOKEN"
  echo "   Luego vuelve a correr este script"
  exit 1
fi

if ! grep -q "LOYVERSE_API_TOKEN=.*[a-zA-Z0-9]" .env; then
  echo "❌ LOYVERSE_API_TOKEN no está configurado en .env"
  exit 1
fi

echo "✅ .env configurado"
echo ""

# 2. Crear base de datos
echo "📦 Creando base de datos..."
bin/rails db:create 2>&1 | grep -v "already exists" || true

# 3. Correr migraciones (reintenta hasta 5 veces)
echo "📋 Corriendo migraciones..."
RETRIES=5
for i in $(seq 1 $RETRIES); do
  if bin/rails db:migrate 2>&1; then
    echo "✅ Migraciones completadas"
    break
  else
    if [ $i -eq $RETRIES ]; then
      echo "❌ Error al correr migraciones después de $RETRIES intentos"
      echo ""
      echo "💡 Posibles soluciones:"
      echo "   1. Verifica que PostgreSQL esté corriendo: docker compose ps"
      echo "   2. Reinicia PostgreSQL: docker compose restart db"
      echo "   3. Verifica logs: docker compose logs db"
      echo "   4. Espera unos segundos y vuelve a intentar"
      exit 1
    fi
    echo "⚠️  Intento $i/$RETRIES falló, reintentando en 5 segundos..."
    sleep 5
  fi
done

echo ""

# 4. Verificar que las tablas de Loyverse existen
echo "🔍 Verificando tablas de Loyverse..."
if bin/rails runner "puts LoyverseConfig.table_exists? ? 'OK' : 'ERROR'" 2>&1 | grep -q "OK"; then
  echo "✅ Tablas de Loyverse creadas correctamente"
else
  echo "❌ Error: Tablas de Loyverse no existen"
  echo "   Verifica las migraciones con: bin/rails db:migrate:status"
  exit 1
fi

echo ""

# 5. Probar conexión
echo "🔌 Probando conexión con Loyverse API..."
if bin/rails loyverse:test_connection; then
  echo ""
  echo "✅ ¡TODO LISTO! Loyverse está configurado correctamente"
  echo ""
  echo "📝 Comandos útiles:"
  echo "   bin/rails loyverse:sync_payment_types     # Sincronizar tipos de pago"
  echo "   bin/rails loyverse:sync_receipts          # Sincronizar receipts"
  echo "   bin/rails loyverse:full_sync              # Sincronización completa"
else
  echo ""
  echo "❌ Error al conectar con Loyverse"
  echo "   Verifica que el token en .env sea correcto"
fi
