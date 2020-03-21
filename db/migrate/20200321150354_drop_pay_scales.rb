class DropPayScales < ActiveRecord::Migration[5.2]
  def change
    drop_table :pay_scales
  end
end
