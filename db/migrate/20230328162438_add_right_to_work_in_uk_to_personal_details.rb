class AddRightToWorkInUkToPersonalDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :personal_details, :right_to_work_in_uk, :boolean
  end
end
