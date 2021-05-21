class RemoveStateFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :state
  end
end
