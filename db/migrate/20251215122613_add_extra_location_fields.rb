class AddExtraLocationFields < ActiveRecord::Migration[8.0]
  def change
    # have to allow nulls on this column as its now being ignored so won't be populated
    change_column_null :job_preferences_locations, :area, true

    # would like to set this, but won't work on existing data
    safety_assured do
      change_column_null :job_preferences_locations, :uk_area, false
    end
  end
end
