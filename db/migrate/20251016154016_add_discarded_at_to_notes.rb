class AddDiscardedAtToNotes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :notes, :discarded_at, :datetime
    add_index :notes, :discarded_at, algorithm: :concurrently
  end
end
