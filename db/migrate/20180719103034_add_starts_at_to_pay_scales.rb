class AddStartsAtToPayScales < ActiveRecord::Migration[5.1]
  def change
    add_column :pay_scales, :starts_at, :date
  end
end
