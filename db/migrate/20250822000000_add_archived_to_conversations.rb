class AddArchivedToConversations < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :conversations, :archived, :boolean, default: false, null: false
    add_index :conversations, :archived, algorithm: :concurrently
  end
end