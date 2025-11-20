#!/bin/bash

# Script para resetear la base de datos y sincronizar Loyverse desde cero
# Uso: ./scripts/reset_and_sync.sh

set -e  # Salir si hay errores

echo "═══════════════════════════════════════════════════════════════"
echo "🔄 RESET COMPLETO DE BASE DE DATOS Y SINCRONIZACIÓN LOYVERSE"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Confirmar acción
read -p "⚠️  ADVERTENCIA: Esto borrará TODOS los datos. ¿Continuar? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelado"
    exit 1
fi

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 1: Drop de la base de datos"
echo "──────────────────────────────────────────────────────────────"
bin/rails db:drop

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 2: Crear base de datos"
echo "──────────────────────────────────────────────────────────────"
bin/rails db:create

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 3: Ejecutar migraciones"
echo "──────────────────────────────────────────────────────────────"
bin/rails db:migrate

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 4: Cargar seeds (usuarios, cuentas, payment methods)"
echo "──────────────────────────────────────────────────────────────"
bin/rails db:seed

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "SINCRONIZACIÓN LOYVERSE"
echo "══════════════════════════════════════════════════════════════"

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 5: Verificar conexión con Loyverse"
echo "──────────────────────────────────────────────────────────────"
bin/rails loyverse:test_connection

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 6: Sincronizar Payment Types de Loyverse"
echo "──────────────────────────────────────────────────────────────"
bin/rails loyverse:sync_payment_types

echo ""
echo "⏸️  PAUSA: Revisa los payment types antes de continuar"
echo ""
bin/rails runner "
  puts '\n📊 Payment Types sincronizados:\n'
  LoyversePaymentMapping.all.each do |mapping|
    status = mapping.mapped? ? '✅' : '⚠️ '
    method = mapping.payment_method&.name || 'SIN MAPEAR'
    puts \"  #{status} #{mapping.loyverse_payment_name} (#{mapping.loyverse_payment_type}) → #{method}\"
  end
  puts ''
"

read -p "¿Continuar con sincronización de shifts? (Y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "⏸️  Pausado. Para continuar después ejecuta:"
    echo "   bin/rails loyverse:sync_shifts[YYYY-MM-DD,YYYY-MM-DD]"
    exit 0
fi

echo ""
echo "──────────────────────────────────────────────────────────────"
echo "PASO 7: Sincronizar SHIFTS (turnos de caja) - Últimos 3 meses"
echo "──────────────────────────────────────────────────────────────"
echo "ℹ️  Esto puede tardar varios minutos..."
echo ""

START_DATE=$(date -d "3 months ago" +%Y-%m-%d 2>/dev/null || date -v-3m +%Y-%m-%d)
END_DATE=$(date +%Y-%m-%d)

echo "📅 Período: ${START_DATE} a ${END_DATE}"
echo ""

bin/rails loyverse:sync_shifts[$START_DATE,$END_DATE]

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ RESET Y SINCRONIZACIÓN COMPLETADOS"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Mostrar resumen
bin/rails runner "
puts '📊 RESUMEN FINAL:\n'
puts '─' * 60
puts \"👥 Usuarios: #{User.count}\"
puts \"🏦 Cuentas: #{Account.count}\"
puts \"💳 Payment Methods: #{PaymentMethod.count}\"
puts \"🔗 Loyverse Mappings: #{LoyversePaymentMapping.count} (#{LoyversePaymentMapping.mapped.count} mapeados)\"
puts \"📋 Shifts sincronizados: #{LoyverseShift.count}\"
puts \"🧾 Receipts sincronizados: #{LoyverseReceipt.count}\"
puts \"💰 TurnClosures creados: #{TurnClosure.count}\"
puts '─' * 60

if TurnClosure.any?
  puts '\n📈 Últimos 5 TurnClosures:'
  TurnClosure.order(closure_date: :desc).limit(5).each do |tc|
    shift_info = tc.loyverse_shift ? \" [Shift: #{tc.loyverse_shift.loyverse_id}]\" : ''
    puts \"  • #{tc.closure_number} - #{tc.closure_date} - $#{tc.total_income}#{shift_info}\"
  end
end
"

echo ""
echo "🎉 Todo listo!"
echo ""
