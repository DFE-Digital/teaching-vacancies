class RemoveDefaultVacancyType < ActiveRecord::Migration[7.2]
  def change
    change_column_default :vacancies, :type, from: "PublishedVacancy", to: nil
  end
end
