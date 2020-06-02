class RemoveNqtFieldFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :newly_qualified_teacher
  end
end
