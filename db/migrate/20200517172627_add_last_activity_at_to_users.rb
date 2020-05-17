class AddLastActivityAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_activity_at, :datetime, null: true
  end
end
