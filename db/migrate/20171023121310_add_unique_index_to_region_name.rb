class AddUniqueIndexToRegionName < ActiveRecord::Migration[5.1]
  def change
    add_index :regions, :name, unique: true
  end
end
