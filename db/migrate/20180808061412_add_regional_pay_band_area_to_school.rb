class AddRegionalPayBandAreaToSchool < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :regional_pay_band_area_id, :uuid, foreign_key: true
    add_index :schools, :regional_pay_band_area_id
  end
end
