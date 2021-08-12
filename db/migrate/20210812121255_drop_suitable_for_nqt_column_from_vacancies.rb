class DropSuitableForNqtColumnFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :suitable_for_nqt, :string
  end
end
