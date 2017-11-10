class AddCodeToRegion < ActiveRecord::Migration[5.1]
  def change
    add_column :regions, :code, :text, null: true
    add_index :regions, :code, unique: true
  end
end
