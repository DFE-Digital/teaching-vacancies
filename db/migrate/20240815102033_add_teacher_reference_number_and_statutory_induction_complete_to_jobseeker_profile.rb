class AddTeacherReferenceNumberAndStatutoryInductionCompleteToJobseekerProfile < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseeker_profiles, :teacher_reference_number_ciphertext, :text
    add_column :jobseeker_profiles, :statutory_induction_complete, :string
  end
end