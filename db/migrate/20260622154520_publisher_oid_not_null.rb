class PublisherOidNotNull < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_not_null_constraint :publishers, :oid, name: "publishers_oid_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :publishers, :oid, name: "publishers_oid_null"

    change_column_null :publishers, :oid, false
    remove_check_constraint :publishers, name: "publishers_oid_null"
  end
end
