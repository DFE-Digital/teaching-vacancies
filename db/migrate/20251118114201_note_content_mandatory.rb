class NoteContentMandatory < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_not_null_constraint :notes, :content, name: "notes_content_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :notes, :content, name: "notes_content_null"

    change_column_null :notes, :content, false
    remove_check_constraint :notes, name: "notes_content_null"
  end
end
