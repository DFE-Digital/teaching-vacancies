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
    PersonalDetails.find_in_batches do |batch|
      PersonalDetails.transaction do
        batch.each do |profile|
          profile.sync_yes_no_booleans
          unless profile.save(touch: false)
            logger.warn "Failed to update profile #{profile.first_name} #{profile.last_name}"
          end
        end
      end
    end
  end
end
