class AddApplicationDataToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :application_data, :jsonb
  end
end
