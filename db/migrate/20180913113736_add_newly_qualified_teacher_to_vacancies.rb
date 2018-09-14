class AddNewlyQualifiedTeacherToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :newly_qualified_teacher, :boolean, null: false, default: false
  end
end
