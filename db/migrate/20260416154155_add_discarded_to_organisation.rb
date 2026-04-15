class AddDiscardedToOrganisation < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :discarded_at, :datetime
  end
end
