class RenameBenefitsToBenefitsDetails < ActiveRecord::Migration[7.0]
  def change
    rename_column :vacancies, :benefits, :benefits_details
  end
end
