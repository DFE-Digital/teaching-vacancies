class AddFlexiWorkingDetailsProvidedToVacancies < ActiveRecord::Migration[7.2]
  def change
    add_column :vacancies, :flexi_working_details_provided, :boolean
  end
end
