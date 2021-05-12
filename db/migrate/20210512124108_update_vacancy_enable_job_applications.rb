class UpdateVacancyEnableJobApplications < ActiveRecord::Migration[6.1]
  def change
    Vacancy.published.where(enable_job_applications: nil).in_batches.each_record do |vacancy|
      vacancy.enable_job_applications = false
      vacancy.save
    end
  end
end
