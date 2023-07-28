class ChangeSchoolGroupMembershipsSchoolIdNullConstraint < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_not_null_constraint :school_group_memberships, :school_id, name: "school_group_memberships_school_id_null", validate: false
    validate_not_null_constraint :school_group_memberships, :school_id, name: "school_group_memberships_school_id_null"

    change_column_null :school_group_memberships, :school_id, false
    remove_check_constraint :school_group_memberships, name: "school_group_memberships_school_id_null"
  end

  def down
    change_column_null :school_group_memberships, :school_id, true
  end
end
