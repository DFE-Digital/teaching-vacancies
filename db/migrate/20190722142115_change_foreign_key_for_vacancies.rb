class ChangeForeignKeyForVacancies < ActiveRecord::Migration[5.2]
  def change
    rename_column :vacancies, :user_id, :publisher_user_id
  end
end
