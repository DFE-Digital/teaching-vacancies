class AddBenefitsToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :benefits, :boolean
  end
end
