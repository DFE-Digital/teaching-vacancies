class CreateSchools < ActiveRecord::Migration[5.1]
  def change
    create_table :schools, id: :uuid do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.string :urn, null: false
      t.string :address, null: false
      t.string :town, null: false
      t.string :county, null: false
      t.string :postcode, null: false
      t.integer :phase
      t.string :url
      t.integer :minimum_age
      t.integer :maximum_age

      t.uuid :school_type_id, index: true
      t.uuid :region_id, index: true

      t.timestamps
    end
  end
end
