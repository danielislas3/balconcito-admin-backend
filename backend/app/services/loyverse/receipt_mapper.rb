module Loyverse
  class ReceiptMapper
    attr_reader :loyverse_receipt

    def initialize(loyverse_receipt)
      @loyverse_receipt = loyverse_receipt
    end

    # Crear TurnClosure desde LoyverseReceipt
    def create_turn_closure
      return loyverse_receipt.turn_closure if loyverse_receipt.converted?

      closure_data = map_to_turn_closure_params

      TurnClosure.transaction do
        turn_closure = TurnClosure.create!(closure_data)
        loyverse_receipt.update!(turn_closure: turn_closure)

        Rails.logger.info("✅ TurnClosure #{turn_closure.closure_number} creado desde Loyverse receipt #{loyverse_receipt.receipt_number}")

        turn_closure
      end
    rescue => e
      Rails.logger.error("❌ Error mapeando receipt: #{e.message}")
      raise
    end

    private

    def map_to_turn_closure_params
      {
        closure_number: generate_closure_number,
        closure_date: loyverse_receipt.loyverse_created_at&.to_date || Date.today,
        closed_by: 'Loyverse',

        # Ingresos por tipo de pago
        cash_collected: calculate_cash_income,
        transfer_income_gross: calculate_transfer_income,
        card_income_gross: calculate_card_income,

        # Totales
        total_income: loyverse_receipt.total_money,
        theoretical_cash: calculate_cash_income,
        payments_withdrawals: 0.0,

        # Usuario por defecto
        user_id: default_user&.id || User.first&.id,

        # Metadata
        notes: "Importado automáticamente desde Loyverse (Receipt ##{loyverse_receipt.receipt_number})"
      }
    end

    def calculate_cash_income
      loyverse_receipt.payments
        .select { |p| p['type'] == 'CASH' }
        .sum { |p| p['money_amount'].to_f }
    end

    def calculate_card_income
      loyverse_receipt.payments
        .select { |p| ['CARD', 'NONINTEGRATEDCARD'].include?(p['type']) }
        .sum { |p| p['money_amount'].to_f }
    end

    def calculate_transfer_income
      # OTHER generalmente son transferencias/QR en Loyverse
      loyverse_receipt.payments
        .select { |p| ['OTHER', 'CUSTOM'].include?(p['type']) }
        .sum { |p| p['money_amount'].to_f }
    end

    def generate_closure_number
      # Formato: LOY-YYYYMMDD-XXX
      date_str = loyverse_receipt.loyverse_created_at.strftime('%Y%m%d')
      sequence = TurnClosure.where("closure_number LIKE ?", "LOY-#{date_str}-%").count + 1
      "LOY-#{date_str}-#{sequence.to_s.rjust(3, '0')}"
    end

    def default_user
      # Buscar usuario de sistema o el primero disponible
      User.find_by(email: 'sistema@balconcito.com') || User.first
    end
  end
end
