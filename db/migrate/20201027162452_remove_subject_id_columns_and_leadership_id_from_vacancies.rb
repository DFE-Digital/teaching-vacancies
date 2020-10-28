class RemoveSubjectIdColumnsAndLeadershipIdFromVacancies < ActiveRecord::Migration[6.0]
  def change
    remove_column :vacancies, :subject_id
    remove_column :vacancies, :first_supporting_subject_id
    remove_column :vacancies, :second_supporting_subject_id
    remove_column :vacancies, :leadership_id
  end
end
