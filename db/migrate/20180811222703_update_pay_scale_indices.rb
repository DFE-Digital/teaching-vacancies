class UpdatePayScaleIndices < ActiveRecord::Migration[5.1]
  def change
    remove_index :pay_scales, column: [:label]
    remove_index :pay_scales, column: [:code, :expires_at]
    add_index :pay_scales,
      [:index, :expires_at, :regional_pay_band_area_id],
      unique: true, name: 'index_expires_at_regional_pay_band_area_index'
    add_index :pay_scales,
      [:code, :expires_at, :regional_pay_band_area_id],
      unique: true, name: 'pay_scales_code_expiry_pay_band_area_index'
    add_index :pay_scales, [:code, :expires_at]
  end
end
