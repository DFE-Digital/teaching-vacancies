namespace :jobseeker_profiles do
  desc "Deactivate jobseeker profiles which do not have a right_to_work_in_uk value"
  task deactivate_incomplete: :environment do
    JobseekerProfile.joins(:personal_details)
                   .where(personal_details: { right_to_work_in_uk: nil })
                   .where(active: true)
                   .update_all(active: false)
  end
end