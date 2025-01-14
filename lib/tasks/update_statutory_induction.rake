namespace :update do
  desc "Update statutory_induction_complete from 'on_track' to 'no' in job_applications and jobseeker_profiles"
  task update_statutory_induction: :environment do
    # Update job_applications
    job_applications_updated = JobApplication.where(statutory_induction_complete: "on_track")
                                              .update_all(statutory_induction_complete: "no")

    # Update jobseeker_profiles
    jobseeker_profiles_updated = JobseekerProfile.where(statutory_induction_complete: "on_track")
                                                 .update_all(statutory_induction_complete: "no")

    puts "#{job_applications_updated} job_applications updated."
    puts "#{jobseeker_profiles_updated} jobseeker_profiles updated."
  end
end
