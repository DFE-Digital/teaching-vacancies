class ChangeInvitationToAppliesInvitedByIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :invitation_to_applies, :invited_by_id, name: "invitation_to_applies_invited_by_id_null", validate: false
    validate_not_null_constraint :invitation_to_applies, :invited_by_id, name: "invitation_to_applies_invited_by_id_null"

    change_column_null :invitation_to_applies, :invited_by_id, false
    remove_check_constraint :invitation_to_applies, name: "invitation_to_applies_invited_by_id_null"
  end

  def down
    change_column_null :invitation_to_applies, :invited_by_id, true
  end
end
