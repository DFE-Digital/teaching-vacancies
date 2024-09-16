namespace :jobseeker_profile do
  desc "Update qualified_teacher_status from 'non_teacher' to 'no'"
  task update_non_teacher_status: :environment do
    JobseekerProfile.where(qualified_teacher_status: :non_teacher).update_all(qualified_teacher_status: :no)
  end
end
