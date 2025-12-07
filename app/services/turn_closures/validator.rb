module TurnClosures
  # Servicio para validar TurnClosure contra datos de Loyverse
  # Detecta discrepancias, faltantes de efectivo, y errores de captura
  class Validator
    attr_reader :turn_closure, :loyverse_shift, :errors, :warnings

    # Umbrales de tolerancia
    TOLERANCE_AMOUNT = 5.0 # $5 pesos de tolerancia
    TOLERANCE_PERCENTAGE = 0.5 # 0.5% de tolerancia

    def initialize(turn_closure, loyverse_shift = nil)
      @turn_closure = turn_closure
      @loyverse_shift = loyverse_shift || find_matching_shift
      @errors = []
      @warnings = []
    end

    # Valida el TurnClosure contra Loyverse
    # Retorna { valid: true/false, errors: [], warnings: [], discrepancies: {} }
    def validate
      return no_shift_found_result unless @loyverse_shift

      validate_totals
      validate_cash
      validate_card_payments
      validate_transfer_payments
      validate_total_income
      detect_suspicious_patterns

      {
        valid: @errors.empty?,
        has_warnings: @warnings.any?,
        errors: @errors,
        warnings: @warnings,
        discrepancies: calculate_discrepancies,
        shift_data: shift_summary,
        reported_data: reported_summary
      }
    end

    # Valida solo los totales sin detalles
    def quick_validate
      return { valid: false, reason: "No shift found" } unless @loyverse_shift

      total_diff = (@turn_closure.total_income - @loyverse_shift.gross_sales).abs

      if total_diff <= TOLERANCE_AMOUNT
        { valid: true, difference: total_diff }
      else
        { valid: false, difference: total_diff, expected: @loyverse_shift.gross_sales }
      end
    end

    private

    # Busca el shift de Loyverse que coincida con este TurnClosure
    def find_matching_shift
      return nil unless @turn_closure.closure_date

      # Buscar shift cerrado en la misma fecha
      LoyverseShift.where(
        "DATE(closed_at) = ?",
        @turn_closure.closure_date
      ).order(closed_at: :desc).first
    end

    # Valida totales generales
    def validate_totals
      expected = @loyverse_shift.gross_sales
      reported = @turn_closure.total_income
      diff = (reported - expected).abs

      if diff > TOLERANCE_AMOUNT && diff > (expected * TOLERANCE_PERCENTAGE / 100)
        if reported < expected
          @errors << {
            type: "shortage",
            field: "total_income",
            message: "Total reportado ($#{reported}) es MENOR que ventas reales ($#{expected})",
            difference: expected - reported,
            severity: "critical"
          }
        else
          @warnings << {
            type: "surplus",
            field: "total_income",
            message: "Total reportado ($#{reported}) es MAYOR que ventas reales ($#{expected})",
            difference: reported - expected,
            severity: "warning"
          }
        end
      end
    end

    # Valida efectivo
    def validate_cash
      payment_totals = @loyverse_shift.calculate_payment_totals
      expected_cash = payment_totals[:cash]
      reported_cash = @turn_closure.cash_collected
      diff = (reported_cash - expected_cash).abs

      if diff > TOLERANCE_AMOUNT
        if reported_cash < expected_cash
          @errors << {
            type: "cash_shortage",
            field: "cash_collected",
            message: "Efectivo reportado ($#{reported_cash}) es MENOR que ventas en efectivo ($#{expected_cash})",
            difference: expected_cash - reported_cash,
            severity: "critical",
            recommendation: "Verificar faltante de efectivo en caja"
          }
        else
          @warnings << {
            type: "cash_surplus",
            field: "cash_collected",
            message: "Efectivo reportado ($#{reported_cash}) es MAYOR que ventas en efectivo ($#{expected_cash})",
            difference: reported_cash - expected_cash,
            severity: "warning",
            recommendation: "Verificar posible error de captura o ventas no registradas"
          }
        end
      end

      # Validar cuadre de efectivo de Loyverse
      if @loyverse_shift.expected_cash && @loyverse_shift.actual_cash
        loyverse_diff = @loyverse_shift.cash_difference

        if loyverse_diff.abs > TOLERANCE_AMOUNT
          status = loyverse_diff.positive? ? "sobrante" : "faltante"
          @warnings << {
            type: "loyverse_cash_mismatch",
            field: "cash_collected",
            message: "Loyverse reporta #{status} de $#{loyverse_diff.abs} en el cuadre de efectivo",
            difference: loyverse_diff,
            severity: "warning",
            recommendation: "Revisar cuadre de efectivo en Loyverse POS"
          }
        end
      end
    end

    # Valida pagos con tarjeta
    def validate_card_payments
      payment_totals = @loyverse_shift.calculate_payment_totals
      expected_card = payment_totals[:card]
      reported_card = @turn_closure.card_income_gross
      diff = (reported_card - expected_card).abs

      if diff > TOLERANCE_AMOUNT
        @warnings << {
          type: "card_discrepancy",
          field: "card_income_gross",
          message: "Tarjetas reportadas ($#{reported_card}) difiere de ventas con tarjeta ($#{expected_card})",
          difference: diff,
          severity: "warning",
          recommendation: "Verificar transacciones con tarjeta en terminal"
        }
      end
    end

    # Valida transferencias
    def validate_transfer_payments
      payment_totals = @loyverse_shift.calculate_payment_totals
      expected_transfer = payment_totals[:custom]
      reported_transfer = @turn_closure.transfer_income_gross
      diff = (reported_transfer - expected_transfer).abs

      if diff > TOLERANCE_AMOUNT
        @warnings << {
          type: "transfer_discrepancy",
          field: "transfer_income_gross",
          message: "Transferencias reportadas ($#{reported_transfer}) difiere de ventas por transferencia ($#{expected_transfer})",
          difference: diff,
          severity: "warning",
          recommendation: "Verificar transacciones por QR/transferencia en Mercado Pago"
        }
      end
    end

    # Valida que el total reportado coincida con la suma de métodos de pago
    def validate_total_income
      reported_total = @turn_closure.total_income
      sum_of_payments = @turn_closure.cash_collected +
                       @turn_closure.card_income_gross +
                       @turn_closure.transfer_income_gross

      diff = (reported_total - sum_of_payments).abs

      if diff > 0.01 # Tolerancia de 1 centavo por redondeo
        @errors << {
          type: "internal_mismatch",
          field: "total_income",
          message: "Total reportado ($#{reported_total}) no coincide con suma de métodos de pago ($#{sum_of_payments})",
          difference: diff,
          severity: "critical",
          recommendation: "Error de captura: revisar los montos ingresados"
        }
      end
    end

    # Detecta patrones sospechosos
    def detect_suspicious_patterns
      # Patrón 1: Todos los pagos son cero
      if @turn_closure.cash_collected.zero? &&
         @turn_closure.card_income_gross.zero? &&
         @turn_closure.transfer_income_gross.zero?
        @errors << {
          type: "suspicious_zero",
          field: "all_payments",
          message: "Todos los métodos de pago son $0 - posible error de captura",
          severity: "critical",
          recommendation: "Ingresar los montos correctos del cierre"
        }
      end

      # Patrón 2: Efectivo es 0 pero hay ventas
      if @turn_closure.cash_collected.zero? && @loyverse_shift.cash_payments > TOLERANCE_AMOUNT
        @warnings << {
          type: "suspicious_no_cash",
          field: "cash_collected",
          message: "Reportas $0 en efectivo pero Loyverse registra $#{@loyverse_shift.cash_payments}",
          severity: "warning",
          recommendation: "Verificar si hubo ventas en efectivo"
        }
      end

      # Patrón 3: Diferencia muy grande (>10% del total)
      payment_totals = @loyverse_shift.calculate_payment_totals
      total_diff = (@turn_closure.total_income - payment_totals[:total]).abs
      percentage_diff = @loyverse_shift.gross_sales > 0 ?
        (total_diff / @loyverse_shift.gross_sales * 100) : 0

      if percentage_diff > 10
        @errors << {
          type: "suspicious_large_difference",
          field: "total_income",
          message: "Diferencia de #{percentage_diff.round(1)}% es muy alta - revisar datos",
          difference: total_diff,
          percentage: percentage_diff.round(2),
          severity: "critical",
          recommendation: "Verificar que los montos ingresados sean correctos"
        }
      end
    end

    # Calcula todas las discrepancias
    def calculate_discrepancies
      payment_totals = @loyverse_shift.calculate_payment_totals

      {
        cash: {
          expected: payment_totals[:cash],
          reported: @turn_closure.cash_collected,
          difference: @turn_closure.cash_collected - payment_totals[:cash]
        },
        card: {
          expected: payment_totals[:card],
          reported: @turn_closure.card_income_gross,
          difference: @turn_closure.card_income_gross - payment_totals[:card]
        },
        transfer: {
          expected: payment_totals[:custom],
          reported: @turn_closure.transfer_income_gross,
          difference: @turn_closure.transfer_income_gross - payment_totals[:custom]
        },
        total: {
          expected: @loyverse_shift.gross_sales,
          reported: @turn_closure.total_income,
          difference: @turn_closure.total_income - @loyverse_shift.gross_sales,
          percentage: calculate_percentage_diff(@turn_closure.total_income, @loyverse_shift.gross_sales)
        }
      }
    end

    # Resumen de datos de Loyverse
    def shift_summary
      payment_totals = @loyverse_shift.calculate_payment_totals

      {
        shift_id: @loyverse_shift.loyverse_id,
        closed_at: @loyverse_shift.closed_at,
        cash: payment_totals[:cash],
        card: payment_totals[:card],
        transfer: payment_totals[:custom],
        total: @loyverse_shift.gross_sales,
        receipts_count: @loyverse_shift.loyverse_receipts.count,
        cash_balanced: @loyverse_shift.cash_balanced?,
        cash_difference: @loyverse_shift.cash_difference
      }
    end

    # Resumen de datos reportados
    def reported_summary
      {
        closure_number: @turn_closure.closure_number,
        closure_date: @turn_closure.closure_date,
        cash: @turn_closure.cash_collected,
        card: @turn_closure.card_income_gross,
        transfer: @turn_closure.transfer_income_gross,
        total: @turn_closure.total_income
      }
    end

    def calculate_percentage_diff(reported, expected)
      return 0 if expected.zero?
      ((reported - expected) / expected * 100).round(2)
    end

    def no_shift_found_result
      {
        valid: false,
        has_warnings: true,
        errors: [ {
          type: "no_shift_found",
          message: "No se encontró shift de Loyverse para esta fecha",
          severity: "warning",
          recommendation: "Verificar que el turno esté cerrado en Loyverse o crear manualmente"
        } ],
        warnings: [],
        discrepancies: {},
        shift_data: nil,
        reported_data: reported_summary
      }
    end
  end
end
