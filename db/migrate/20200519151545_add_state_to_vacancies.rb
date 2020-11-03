class AddStateToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :state, :string, default: "create"
  end
end
