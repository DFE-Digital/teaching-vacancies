class RemoveVacancyHeadline < ActiveRecord::Migration[5.1]
  def change
    remove_column :vacancies, :headline
  end
end
