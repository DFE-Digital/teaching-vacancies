class AddRegionalPayBandAreaToPayScale < ActiveRecord::Migration[5.1]
  def change
    add_column :pay_scales, :regional_pay_band_area_id, :uuid, foreign_key: true
    add_index :pay_scales, :regional_pay_band_area_id
  end
end
