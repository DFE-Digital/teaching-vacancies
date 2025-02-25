class RemoveCurrentRoleFromEmployment < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :employments, :current_role, :string, default: "", null: false }
  end
end
