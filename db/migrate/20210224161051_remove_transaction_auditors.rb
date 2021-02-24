class RemoveTransactionAuditors < ActiveRecord::Migration[6.1]
  def change
    drop_table :transaction_auditors
  end
end
