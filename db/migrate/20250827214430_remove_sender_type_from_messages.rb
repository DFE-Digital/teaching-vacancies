class RemoveSenderTypeFromMessages < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    remove_index :messages, name: :index_messages_on_sender, algorithm: :concurrently
    safety_assured { remove_column :messages, :sender_type, :string }
  end
end
