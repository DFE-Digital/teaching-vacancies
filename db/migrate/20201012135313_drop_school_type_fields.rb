class DropSchoolTypeFields < ActiveRecord::Migration[6.0]
  def change
    remove_index :organisations, name: "index_organisations_on_school_type_id"
    remove_index :organisations, name: "index_organisations_on_detailed_school_type_id"
    remove_column :organisations, :school_type_id
    remove_column :organisations, :detailed_school_type_id
    drop_table :school_types
    drop_table :detailed_school_types
  end
end
