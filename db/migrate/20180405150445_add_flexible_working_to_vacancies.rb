class AddFlexibleWorkingToVacancies < ActiveRecord::Migration[5.1]
  def change
    add_column :vacancies, :flexible_working, :boolean
  end
end
