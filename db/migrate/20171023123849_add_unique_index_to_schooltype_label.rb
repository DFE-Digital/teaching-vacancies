class AddUniqueIndexToSchooltypeLabel < ActiveRecord::Migration[5.1]
  def change
    add_index :school_types, :label, unique: true
  end
end
