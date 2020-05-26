class AddSubjectsToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :subjects, :string, array: true
  end
end
