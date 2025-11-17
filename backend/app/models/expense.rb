class Expense < ApplicationRecord
  belongs_to :user
  has_many :reimbursement_expenses, dependent: :restrict_with_error
  has_many :reimbursements, through: :reimbursement_expenses

  # Enums
  enum :category, {
    # COGS (Cost of Goods Sold) - Costo de lo que vendes
    beer: 'cerveza',
    draft_beer: 'cerveza_barril',
    wines_liquors: 'vinos_licores',
    sodas_juices: 'refrescos_jugos',
    food: 'alimentos',
    disposables: 'desechables',
    ice: 'hielo',
    dry_supplies: 'insumos_secos',

    # Costos Fijos
    rent: 'renta',
    payroll: 'nomina',
    utilities: 'servicios', # luz, agua, gas
    financial: 'gastos_financieros', # comisiones Mercado Pago
    debt_payment: 'pago_deuda',

    # Costos Variables
    maintenance: 'mantenimiento',
    staff_expenses: 'gastos_staff',
    miscellaneous: 'gastos_varios'
  }, validate: true

  enum :payment_source, {
    cash_petty: 'efectivo_caja_chica',
    cash_vault: 'efectivo_boveda',
    mercadopago_transfer: 'transferencia_negocio',
    business_card: 'tarjeta_negocio',
    daniel_card: 'tarjeta_daniel',
    raul_card: 'tarjeta_raul'
  }, validate: true

  # Validations
  validates :expense_date, :amount, :description, :category, :payment_source, presence: true
  validates :amount, numericality: { greater_than: 0 }

  # Scopes
  scope :pending_reimbursement, -> { where(requires_reimbursement: true, reimbursed: false) }
  scope :by_date_range, ->(start_date, end_date) { where(expense_date: start_date..end_date) }

  # Callbacks
  before_create :check_if_requires_reimbursement
  after_create :update_account_balance

  # Instance methods
  def cost_type
    case category.to_sym
    when :beer, :draft_beer, :wines_liquors, :sodas_juices, :food,
         :disposables, :ice, :dry_supplies
      'cogs' # Cost of Goods Sold
    when :rent, :payroll, :utilities, :financial, :debt_payment
      'fixed' # Costos Fijos
    when :maintenance, :staff_expenses, :miscellaneous
      'variable' # Costos Variables
    end
  end

  private

  def check_if_requires_reimbursement
    self.requires_reimbursement = daniel_card? || raul_card?
  end

  def update_account_balance
    return if requires_reimbursement # Las tarjetas personales no afectan cuentas del negocio

    account = case payment_source.to_sym
              when :cash_petty then Account.find_by(account_type: 'petty_cash')
              when :cash_vault then Account.find_by(account_type: 'physical_cash')
              when :mercadopago_transfer then Account.find_by(name: 'Mercado Pago')
              when :business_card then nil # TODO: Implementar tarjeta de crédito del negocio
              end

    account&.decrement!(:current_balance, amount)
  end
end
