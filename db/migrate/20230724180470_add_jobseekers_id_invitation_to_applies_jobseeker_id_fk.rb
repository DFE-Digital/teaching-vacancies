class AddJobseekersIdInvitationToAppliesJobseekerIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :invitation_to_applies, :jobseekers, column: :jobseeker_id, primary_key: :id, validate: false
    validate_foreign_key :invitation_to_applies, :jobseekers
  end
end
