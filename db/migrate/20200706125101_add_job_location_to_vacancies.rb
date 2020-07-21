class AddJobLocationToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :job_location, :string
  end
end
