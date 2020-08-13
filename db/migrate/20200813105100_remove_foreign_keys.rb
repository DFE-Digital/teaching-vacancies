class RemoveForeignKeys < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :user_preferences, :school_groups
    remove_foreign_key :vacancies, :school_groups
  end
end
