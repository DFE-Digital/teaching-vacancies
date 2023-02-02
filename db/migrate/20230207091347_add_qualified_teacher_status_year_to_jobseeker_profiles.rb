class AddQualifiedTeacherStatusYearToJobseekerProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :jobseeker_profiles, :qualified_teacher_status_year, :string
  end
end
