class AddReadableJobLocationToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :readable_job_location, :string
  end
end
