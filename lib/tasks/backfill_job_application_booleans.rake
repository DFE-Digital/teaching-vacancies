namespace :job_applications do
  desc "backfill yes/no booleans for job applications"
  task backfill_booleans: :environment do
    # we only need to update the 'current' jobs (71k) as the default on the migration was 'false'
    JobApplication.find_in_batches do |batch|
      JobApplication.transaction do
        batch.each do |job_application|
          job_application.sync_yes_no_booleans
          unless job_application.save(touch: false)
            logger.warn "Failed to update job application #{job_application.email}"
          end
        end
      end
    end
    JobseekerProfile.find_in_batches do |batch|
      JobseekerProfile.transaction do
        batch.each do |profile|
          profile.sync_yes_no_booleans
          profile.personal_details.sync_yes_no_booleans if profile.personal_details.present?
          unless profile.save(touch: false)
            logger.warn "Failed to update profile #{profile.first_name} #{profile.last_name}"
          end
        end
      end
    end
  end
end
