class CreateDetailedSchoolTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :detailed_school_types, id: :uuid do |t|
      t.string :code
      t.text :label
    end

    add_index :detailed_school_types, :code, unique: true

    add_column :schools, :detailed_school_type_id, :uuid, null: true
    add_foreign_key :schools, :detailed_school_types


  end
end
