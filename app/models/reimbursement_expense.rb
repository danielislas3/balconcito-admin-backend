class ReimbursementExpense < ApplicationRecord
  belongs_to :reimbursement
  belongs_to :expense
end
