class AddReadToMessages < ActiveRecord::Migration[7.2]
  def change
    add_column :messages, :read, :boolean, default: false, null: false
  end
end
