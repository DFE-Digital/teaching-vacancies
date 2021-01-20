class AddJobseekerIdAndVacancyIdToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :jobseeker_id, :uuid
    add_column :job_applications, :vacancy_id, :uuid
  end
end
