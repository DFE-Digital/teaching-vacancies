class ConvertCurrentRoleToBoolean < ActiveRecord::Migration[7.2]
  def change
    add_column :employments, :is_current_role, :boolean, null: false, default: false
  end
end
