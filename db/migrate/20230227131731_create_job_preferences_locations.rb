require 'geocoding'

class CreateJobPreferencesLocations < ActiveRecord::Migration[7.0]
  class JobPreferences < ActiveRecord::Base
    has_many :location_records, class_name: 'JobPreferencesLocations'
  end

  class JobPreferencesLocations < ActiveRecord::Base
    include DistanceHelper

    belongs_to :job_preferences
    before_create :set_area

    def set_area
      if LocationPolygon.contain?(name)
        self.area = LocationPolygon.buffered(radius).with_name(name).area
      else
        long, lat = Geocoding.new(name).coordinates
        radius = convert_miles_to_metres(self.radius)
        self.area = self.class.select("ST_Buffer(ST_MakePoint(#{long}, #{lat}), #{radius}) AS area").first.area
      end
    end
  end

  def change
    create_table :job_preferences_locations, id: :uuid do |t|
      t.references :job_preferences, type: :uuid, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :radius, null: false
      t.geometry :area, geographic: true, null: false
      t.timestamps

      t.index :area, using: :gist
    end

    reversible do |dir|
      dir.up do
        JobPreferences.reset_column_information
        JobPreferences.find_each do |jp|
          jp.locations.each do |location_hash|
            jp.location_records.create!(
              name: location_hash['location'],
              radius: location_hash['radius']
            )
          end
        end
      end

      dir.down do
        JobPreferences.find_each do |jp|
          hash = jp.location_records.pluck(:name, :radius).map {|data| %w[location radius].zip(data.map(&:to_s)).to_h }
          jp.update!(locations: hash)
        end
      end
    end

    remove_column :job_preferences, :locations, :json, array: true, default: []
  end
end
