class AddJobseekersIdJobApplicationsJobseekerIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :job_applications, :jobseekers, column: :jobseeker_id, primary_key: :id, validate: false
    validate_foreign_key :job_applications, :jobseekers
  end
end
