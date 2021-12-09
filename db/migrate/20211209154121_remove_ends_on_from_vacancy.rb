class RemoveEndsOnFromVacancy < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :ends_on, :date
  end
end
