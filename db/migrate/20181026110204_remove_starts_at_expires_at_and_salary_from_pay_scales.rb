class RemoveStartsAtExpiresAtAndSalaryFromPayScales < ActiveRecord::Migration[5.2]
  def change
    remove_column :pay_scales, :salary, :integer
    remove_column :pay_scales, :starts_at, :datetime
    remove_column :pay_scales, :expires_at, :datetime
  end
end
