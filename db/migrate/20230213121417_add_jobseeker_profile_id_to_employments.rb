class AddJobseekerProfileIdToEmployments < ActiveRecord::Migration[7.0]
  def change
    add_reference :employments, :jobseeker_profile, index: true, optional: true, type: :uuid
  end
end
