class AddSuitableForNqtToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :suitable_for_nqt, :string
  end
end
