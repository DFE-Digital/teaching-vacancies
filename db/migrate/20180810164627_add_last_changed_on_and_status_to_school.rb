class AddLastChangedOnAndStatusToSchool < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :last_changed_on, :date
    add_column :schools, :status, :string
    add_index :schools, :last_changed_on
    add_index :schools, :status
  end
end
