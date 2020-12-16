class AddStartAsapToVacancies < ActiveRecord::Migration[6.0]
  def change
    add_column :vacancies, :starts_asap, :boolean, default: false
  end
end
