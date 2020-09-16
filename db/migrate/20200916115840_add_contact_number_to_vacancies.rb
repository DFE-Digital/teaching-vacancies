class AddContactNumberToVacancies < ActiveRecord::Migration[6.0]
  def change
    add_column :vacancies, :contact_number, :string
  end
end
