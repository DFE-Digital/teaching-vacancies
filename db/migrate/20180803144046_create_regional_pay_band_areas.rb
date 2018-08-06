class CreateRegionalPayBandAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :regional_pay_band_areas, id: :uuid do |t|
      t.string :name

      t.timestamps
    end

    add_index :regional_pay_band_areas, :name, unique: true
  end
end
