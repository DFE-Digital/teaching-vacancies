class AddManagedSchoolUrnsToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :managed_school_urns, :string, array: true
  end
end
