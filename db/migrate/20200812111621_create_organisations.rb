class CreateOrganisations < ActiveRecord::Migration[5.2]
  def change
    create_table :organisations, id: :uuid do |t|
      t.string :type
      t.string :name
      t.text :description
      t.string :urn, index: true
      t.string :uid, index: true
      t.integer :phase
      t.string :url
      t.integer :minimum_age
      t.integer :maximum_age

      t.string :address
      t.string :town
      t.string :county
      t.string :postcode
      t.string :local_authority
      t.text :locality
      t.text :address3
      t.text :easting
      t.text :northing
      t.point :geolocation
      t.json :gias_data

      t.uuid :school_type_id, index: true
      t.uuid :region_id, index: true
      t.uuid :detailed_school_type_id, index: true

      t.timestamps
    end
  end
end
