class ChangeManagedSchoolUrnsToManagedSchoolIds < ActiveRecord::Migration[5.2]
  def change
    rename_column :user_preferences, :managed_school_urns, :managed_school_ids
  end
end
