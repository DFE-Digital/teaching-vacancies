class AddJobApplicationsJobseekerIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :job_applications, ["jobseeker_id"], name: :index_job_applications_jobseeker_id, algorithm: :concurrently
  end
end
