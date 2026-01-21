class AddExtraLocationFields < ActiveRecord::Migration[8.0]
  def change
    # have to allow nulls on this column as its now being ignored so won't be populated
    change_column_null :job_preferences_locations, :area, true
  end
end
