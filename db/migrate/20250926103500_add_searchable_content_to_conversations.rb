class AddSearchableContentToConversations < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :conversations, :searchable_content, :tsvector
    add_index :conversations, :searchable_content, using: :gin, algorithm: :concurrently
  end
end
