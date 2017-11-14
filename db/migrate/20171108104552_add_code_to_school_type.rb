class AddCodeToSchoolType < ActiveRecord::Migration[5.1]
  def change
    add_column :school_types, :code, :text, null: true
    add_index :school_types, :code, unique: true
  end
end
