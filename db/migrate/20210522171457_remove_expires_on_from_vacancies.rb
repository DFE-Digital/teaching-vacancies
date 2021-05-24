class RemoveExpiresOnFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :expires_on
  end
end
