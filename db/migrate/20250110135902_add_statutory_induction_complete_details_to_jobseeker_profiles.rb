class AddStatutoryInductionCompleteDetailsToJobseekerProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :jobseeker_profiles, :statutory_induction_complete_details, :string
  end
end
