class RemoveReferenceFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :reference
  end
end
