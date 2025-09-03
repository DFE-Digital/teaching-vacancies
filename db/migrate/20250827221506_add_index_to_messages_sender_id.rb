class AddIndexToMessagesSenderId < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :messages, :sender_id, algorithm: :concurrently
  end
end
