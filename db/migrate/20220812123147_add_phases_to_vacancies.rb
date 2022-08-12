class AddPhasesToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :phases, :integer, array: true
  end
end
