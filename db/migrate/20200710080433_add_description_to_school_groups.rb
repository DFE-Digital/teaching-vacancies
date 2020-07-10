class AddDescriptionToSchoolGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :school_groups, :description, :text
  end
end
