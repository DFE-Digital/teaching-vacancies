class RemoveHasTeacherReferenceNumberFromJobseekerProfiles < ActiveRecord::Migration[7.2]
  def change
    safety_assured { remove_column :jobseeker_profiles, :has_teacher_reference_number }
  end
end
