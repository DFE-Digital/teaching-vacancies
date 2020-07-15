class AddSchoolGroupRefToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_preferences, :school_group, foreign_key: true, type: :uuid
  end
end
