class AddFlexiWorkingDetailsProvidedToVacancies < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :vacancies, :flexi_working_details_provided, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
