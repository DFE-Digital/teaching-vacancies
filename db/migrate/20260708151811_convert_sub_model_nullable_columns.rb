class ConvertSubModelNullableColumns < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_not_null_constraint :training_and_cpds, :name, name: "training_and_cpds_name_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :training_and_cpds, :name, name: "training_and_cpds_name_null"

    change_column_null :training_and_cpds, :name, false
    remove_check_constraint :training_and_cpds, name: "training_and_cpds_name_null"

    add_not_null_constraint :training_and_cpds, :year_awarded, name: "training_and_cpds_year_awarded_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :training_and_cpds, :year_awarded, name: "training_and_cpds_year_awarded_null"
    change_column_null :training_and_cpds, :year_awarded, false
    remove_check_constraint :training_and_cpds, name: "training_and_cpds_year_awarded_null"

    add_not_null_constraint :professional_body_memberships, :name, name: "professional_body_memberships_name_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :professional_body_memberships, :name, name: "professional_body_memberships_name_null"

    change_column_null :professional_body_memberships, :name, false
    remove_check_constraint :professional_body_memberships, name: "professional_body_memberships_name_null"
  end
end
