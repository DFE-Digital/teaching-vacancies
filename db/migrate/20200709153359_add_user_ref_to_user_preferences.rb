class AddUserRefToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_preferences, :user, foreign_key: true, type: :uuid
  end
end
