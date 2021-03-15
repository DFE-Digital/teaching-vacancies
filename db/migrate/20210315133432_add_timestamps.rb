class AddTimestamps < ActiveRecord::Migration[6.1]
  def change
    add_timestamps(:organisation_vacancies, null: true)
    add_timestamps(:publisher_preferences, null: true)
    add_timestamps(:publishers, null: true)
    add_timestamps(:school_group_memberships, null: true)
  end
end
