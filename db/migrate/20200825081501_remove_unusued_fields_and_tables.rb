class RemoveUnusuedFieldsAndTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :schools
    drop_table :school_groups
    remove_column :vacancies, :school_id, :uuid
    remove_column :vacancies, :school_group_id, :uuid
  end
end
