class RemoveEssentialRequirementsFromVacancy < ActiveRecord::Migration[5.1]
  def change
    remove_column :vacancies, :essential_requirements, :string
  end
end
