class CreateUserPreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :user_preferences, id: :uuid do |t|
      t.string :managed_organisations
    end
  end
end
