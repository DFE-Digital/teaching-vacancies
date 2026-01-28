class AddExtraLocationFields < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # have to allow nulls on this column as its now being ignored so won't be populated
    change_column_null :job_preferences_locations, :area, true

    add_not_null_constraint :job_preferences_locations, :uk_area, name: "job_preferences_locations_uk_area_null", validate: false
    # You can use `validate_constraint_in_background` if you have a very large table
    # and want to validate the constraint using background schema migrations.
    validate_not_null_constraint :job_preferences_locations, :uk_area, name: "job_preferences_locations_uk_area_null"

    change_column_null :job_preferences_locations, :uk_area, false
    remove_check_constraint :job_preferences_locations, name: "job_preferences_locations_uk_area_null"
  end
end
