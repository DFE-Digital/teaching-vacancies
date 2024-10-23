namespace :jobseeker_profile do
  desc "Migrate Teacher Reference Number (TRN) from job_applications to jobseeker_profiles, creating profiles if necessary"
  task migrate_teacher_reference_number_to_profiles: :environment do
    batch_size = 500

    JobApplication
      .select("DISTINCT job_applications.jobseeker_id, job_applications.teacher_reference_number_ciphertext")
      .where.not(teacher_reference_number_ciphertext: [nil, ""])
      .joins("LEFT JOIN jobseeker_profiles ON jobseeker_profiles.jobseeker_id = job_applications.jobseeker_id")
      .where("jobseeker_profiles.teacher_reference_number_ciphertext IS NULL OR jobseeker_profiles.teacher_reference_number_ciphertext = ''")
      .find_in_batches(batch_size: batch_size) do |applications|
      applications.each do |application|
        profile = JobseekerProfile.find_or_initialize_by(jobseeker_id: application.jobseeker_id)

        puts "Creating profile for jobseeker ID: #{application.jobseeker_id}" if profile.new_record?

        profile.teacher_reference_number_ciphertext = application.teacher_reference_number_ciphertext
        profile.has_teacher_reference_number = "yes"

        if profile.save
          puts "Migrated TRN for profile ID: #{profile.id} (jobseeker ID: #{application.jobseeker_id})"
        else
          puts "Failed to save profile for jobseeker ID: #{application.jobseeker_id}. Errors: #{profile.errors.full_messages.join(', ')}"
        end
      end
    end

    puts "Teacher Reference Number migration completed."
  end
end
