class AddContactNumberProvidedToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :contact_number_provided, :boolean
  end
end
