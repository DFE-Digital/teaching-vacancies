# rubocop:disable Metrics/BlockLength
namespace :jobseeker_profile do
  desc "Migrate Teacher Reference Number (TRN) from job_applications to jobseeker_profiles, creating profiles if necessary"
  task migrate_teacher_reference_number_to_profiles: :environment do
    batch_size = 500
    failed_log = File.open("failed_migrations.log", "w")

    latest_application_ids = JobApplication
                               .where.not(teacher_reference_number_ciphertext: [nil, ""])
                               .select("DISTINCT ON (jobseeker_id) id")
                               .order(:jobseeker_id, created_at: :desc)
                               .pluck(:id)

    JobApplication
      .where(id: latest_application_ids)
      .find_each(batch_size: batch_size) do |application|
      profile = JobseekerProfile.find_or_initialize_by(jobseeker_id: application.jobseeker_id)

      if profile.teacher_reference_number.blank?
        if profile.update(teacher_reference_number: application.teacher_reference_number, has_teacher_reference_number: "yes")
          puts "Migrated TRN for profile ID: #{profile.id} (jobseeker ID: #{application.jobseeker_id})"
        else
          failed_log.puts("Failed to save profile for Jobseeker ID: #{application.jobseeker_id}, Application ID: #{application.id}. Errors: #{profile.errors.full_messages.join(', ')}")
        end
      else
        puts "Profile already has TRN for jobseeker ID: #{application.jobseeker_id}"
      end
    end

    failed_log.close
    puts "Teacher Reference Number migration completed. Check 'failed_migrations.log' for any failures."
  end
end
# rubocop:enable Metrics/BlockLength
