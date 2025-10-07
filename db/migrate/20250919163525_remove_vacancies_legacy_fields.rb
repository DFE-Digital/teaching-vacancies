class RemoveVacanciesLegacyFields < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_column :vacancies, :safeguarding_information_provided, :boolean
      remove_column :vacancies, :safeguarding_information, :string
    end
  end
end
