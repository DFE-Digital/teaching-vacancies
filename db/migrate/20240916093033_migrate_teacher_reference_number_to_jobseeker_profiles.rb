class MigrateTeacherReferenceNumberToJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    JobseekerProfile.find_in_batches(batch_size: 500) do |profiles|
      profiles.each do |profile|
        latest_job_application = JobApplication.where(jobseeker_id: profile.jobseeker_id).order(created_at: :desc).first

        if latest_job_application&.teacher_reference_number.present?
          profile.update(teacher_reference_number: latest_job_application.teacher_reference_number)
        end
      end
    end
  end
end
