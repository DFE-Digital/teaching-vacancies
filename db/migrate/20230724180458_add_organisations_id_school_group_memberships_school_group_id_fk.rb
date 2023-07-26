class AddOrganisationsIdSchoolGroupMembershipsSchoolGroupIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :school_group_memberships, :organisations, column: :school_group_id, primary_key: :id, validate: false
    validate_foreign_key :school_group_memberships, :organisations
  end
end
