class AddIsParentalLeaveCoverToVacancies < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :is_parental_leave_cover, :boolean
  end
end
