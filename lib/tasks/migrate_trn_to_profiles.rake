namespace :jobseeker_profile do
  desc "Migrate Teacher Reference Number (TRN) from job_applications to jobseeker_profiles"
  task migrate_teacher_reference_number_to_profiles: :environment do
    batch_size = 500

    JobseekerProfile.find_in_batches(batch_size: batch_size) do |profiles|
      profiles.each do |profile|
        latest_job_application = JobApplication
                                   .where(jobseeker_id: profile.jobseeker_id)
                                   .order(created_at: :desc)
                                   .first

        if latest_job_application&.teacher_reference_number.present?
          profile.update(teacher_reference_number: latest_job_application.teacher_reference_number)
          puts "Migrated TRN for profile ID: #{profile.id}"
        end
      end
    end

    puts "Teacher Reference Number migration completed."
  end
end
