class RemoveFlexibleWorkingFromVacancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :vacancies, :flexible_working, :boolean
  end
end
