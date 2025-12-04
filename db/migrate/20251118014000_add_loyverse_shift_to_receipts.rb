class AddLoyverseShiftToReceipts < ActiveRecord::Migration[8.1]
  def change
    add_reference :loyverse_receipts, :loyverse_shift, foreign_key: true, index: true
  end
end
