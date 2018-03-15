class AddUniqueIndexToPayScaleCodeAndExpiresOn < ActiveRecord::Migration[5.1]
  def change
    add_index :pay_scales, [:code, :expires_at], unique: true
  end
end
