class AddHasTeacherReferenceNumberToJobseekerProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseeker_profiles, :has_teacher_reference_number, :string
  end
end
