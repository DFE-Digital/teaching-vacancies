class ProfessionalMembershipJobApplication < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_index :professional_body_memberships, :jobseeker_profile_id, algorithm: :concurrently
    safety_assured { remove_column :professional_body_memberships, :jobseeker_profile_id, :uuid }

    add_not_null_constraint :professional_body_memberships, :job_application_id, name: "professional_body_memberships_job_application_id_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :professional_body_memberships, :job_application_id, name: "professional_body_memberships_job_application_id_null"

    change_column_null :professional_body_memberships, :job_application_id, false
    remove_check_constraint :professional_body_memberships, name: "professional_body_memberships_job_application_id_null"
  end
end
