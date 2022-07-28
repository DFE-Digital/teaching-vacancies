class AddECTStatusToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :ect_status, :integer
  end
end
