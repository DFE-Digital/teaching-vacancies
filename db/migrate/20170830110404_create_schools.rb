class CreateSchools < ActiveRecord::Migration[5.1]
  def change
    create_table :schools do |t|
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

      t.references :school_type, index: true
      t.references :region, index: true

      t.timestamps
    end
  end
end
