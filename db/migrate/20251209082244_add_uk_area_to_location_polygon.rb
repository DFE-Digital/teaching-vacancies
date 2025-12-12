class AddUkAreaToLocationPolygon < ActiveRecord::Migration[8.0]
  # for adding indexes
  disable_ddl_transaction!

  def change
    # could be polygon or multi_polygon
    add_column :location_polygons, :uk_area, :geometry, srid: 27_700
    add_index :location_polygons, :uk_area, using: :gist, algorithm: :concurrently

    add_column :location_polygons, :uk_centroid, :st_point, srid: 27_700
    add_index :location_polygons, :uk_centroid, using: :gist, algorithm: :concurrently

    add_column :subscriptions, :uk_area, :st_polygon, srid: 27_700
    add_column :subscriptions, :uk_geopoint, :st_point, srid: 27_700
    add_index :subscriptions, :uk_area, using: :gist, algorithm: :concurrently
    add_index :subscriptions, :uk_geopoint, using: :gist, algorithm: :concurrently

    add_column :organisations, :uk_geopoint, :st_point, srid: 27_700
    add_index :organisations, :uk_geopoint, using: :gist, algorithm: :concurrently

    add_column :job_preferences_locations, :uk_area, :st_polygon, srid: 27_700
    add_index :job_preferences_locations, :uk_area, using: :gist, algorithm: :concurrently

    # could be point or multi_point if vacancy is in multiple locations
    add_column :vacancies, :uk_geolocation, :geometry, srid: 27_700
    add_index :vacancies, :uk_geolocation, using: :gist, algorithm: :concurrently
  end
end
