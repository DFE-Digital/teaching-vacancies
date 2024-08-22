namespace :jobseeker_profile do
  desc "Update qualified_teacher_status from 'non_teacher' to 'no'"
  task update_non_teacher_status: :environment do
    profiles_to_update = JobseekerProfile.where(qualified_teacher_status: :non_teacher)

    profiles_to_update.each do |profile|
      profile.update(qualified_teacher_status: :no)
    end
  end
end
