class AddKeyStagesToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :key_stages, :integer, array: true
  end
end
