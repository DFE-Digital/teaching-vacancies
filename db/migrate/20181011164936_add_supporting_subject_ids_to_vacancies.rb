class AddSupportingSubjectIdsToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :first_supporting_subject_id, :uuid
    add_column :vacancies, :second_supporting_subject_id, :uuid
  end
end
