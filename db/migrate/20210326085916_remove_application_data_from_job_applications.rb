class RemoveApplicationDataFromJobApplications < ActiveRecord::Migration[6.1]
  def change
    remove_column :job_applications, :application_data
  end
end
