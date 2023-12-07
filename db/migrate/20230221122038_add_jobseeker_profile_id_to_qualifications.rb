class AddJobseekerProfileIdToQualifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :qualifications, :jobseeker_profile, index: true, type: :uuid
  end
end
