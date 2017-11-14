class AddLocalityAndAddress3ToSchools < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :locality, :text
    add_column :schools, :address3, :text
  end
end
