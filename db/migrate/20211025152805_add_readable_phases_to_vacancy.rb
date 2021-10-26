class AddReadablePhasesToVacancy < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :readable_phases, :string, array: true, default: []
  end
end
