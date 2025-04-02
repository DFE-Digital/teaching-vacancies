# delete once store-trn-in-job-application branch has been merged
#
namespace :job_application do
  desc "Migrate Teacher Reference Number (TRN) from jobseeker_profiles back to job_applications"
  task migrate_trn: :environment do
    JobApplication.includes(jobseeker: :jobseeker_profile).find_in_batches.each do |batch|
      JobApplication.transaction do
        batch.select { |ja| ja.teacher_reference_number.blank? && ja.jobseeker&.jobseeker_profile.present? }.each do |job_application|
          job_application.assign_attributes(teacher_reference_number: job_application.jobseeker.jobseeker_profile.teacher_reference_number)
          job_application.save!(validate: false, touch: false)
        end
      end
    end
  end
end
