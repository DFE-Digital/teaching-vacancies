class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :schools, :detailed_school_type_id
    add_index :vacancies, :first_supporting_subject_id
    add_index :vacancies, :max_pay_scale_id
    add_index :vacancies, :second_supporting_subject_id
  end
end
