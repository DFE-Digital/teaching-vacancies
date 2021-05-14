class RemoveCandidateSpecFieldsFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :education
    remove_column :vacancies, :qualifications
    remove_column :vacancies, :experience
  end
end
