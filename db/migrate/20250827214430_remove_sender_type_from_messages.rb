class RemoveSenderTypeFromMessages < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    remove_index :messages, name: :index_messages_on_sender, algorithm: :concurrently
    safety_assured { remove_column :messages, :sender_type, :string }
  end

  def down
    safety_assured { add_column :messages, :sender_type, :string }
    add_index :messages, %i[sender_type sender_id], name: :index_messages_on_sender, algorithm: :concurrently
  end
end
