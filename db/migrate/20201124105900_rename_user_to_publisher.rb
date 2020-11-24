class RenameUserToPublisher < ActiveRecord::Migration[6.0]
  def change
    rename_table :users, :publishers
    rename_table :user_preferences, :publisher_preferences

    rename_column :emergency_login_keys, :user_id, :publisher_id
    rename_column :publisher_preferences, :user_id, :publisher_id
    rename_column :vacancies, :publisher_user_id, :publisher_id
    rename_column :vacancy_publish_feedbacks, :user_id, :publisher_id
  end
end
