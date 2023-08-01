class ChangeInvitationToAppliesJobseekerIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :invitation_to_applies, :jobseeker_id, name: "invitation_to_applies_jobseeker_id_null", validate: false
    validate_not_null_constraint :invitation_to_applies, :jobseeker_id, name: "invitation_to_applies_jobseeker_id_null"

    change_column_null :invitation_to_applies, :jobseeker_id, false
    remove_check_constraint :invitation_to_applies, name: "invitation_to_applies_jobseeker_id_null"
  end

  def down
    change_column_null :invitation_to_applies, :jobseeker_id, true
  end
end
