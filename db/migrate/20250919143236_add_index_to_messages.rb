class AddIndexToMessages < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :messages, %i[type created_at], where: "read = false", name: "index_messages_unread_on_type_created_at", algorithm: :concurrently
  end
end
