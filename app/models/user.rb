class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :turn_closures, dependent: :restrict_with_error
  has_many :expenses, dependent: :restrict_with_error
  has_many :payment_methods, dependent: :destroy
  has_many :reimbursements_received, class_name: "Reimbursement", foreign_key: "to_user_id", dependent: :restrict_with_error
  has_many :reimbursements_created, class_name: "Reimbursement", foreign_key: "user_id", dependent: :restrict_with_error
  has_one :payroll_employee, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :credit_purchases, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin manager employee] }
end
