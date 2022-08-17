class AddReceiveApplicationsToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :receive_applications, :integer
  end
end
