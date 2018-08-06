class CreateLocalAuthorityRegionalPayBandAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :local_authority_regional_pay_band_areas, id: :uuid do |t|
      t.uuid :local_authority_id, foreign_key: true
      t.uuid :regional_pay_band_area_id, foreign_key: true

      t.timestamps
    end

    add_index :local_authority_regional_pay_band_areas,
      [:local_authority_id, :regional_pay_band_area_id],
      unique: true, name: 'la_regional_pay_band_areas_index'
  end
end
