class ChangeJobPreferencesLocationsUkAreaType < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :job_preferences_locations, :new_uk_area, :geometry, srid: 27_700
    add_index :job_preferences_locations, :new_uk_area, using: :gist, algorithm: :concurrently
    remove_index :job_preferences_locations, :uk_area, algorithm: :concurrently
    safety_assured do
      remove_column :job_preferences_locations, :uk_area, :st_polygon, srid: 27_700
      rename_column :job_preferences_locations, :new_uk_area, :uk_area
    end
  end
end
