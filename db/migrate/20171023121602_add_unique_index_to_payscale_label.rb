class AddUniqueIndexToPayscaleLabel < ActiveRecord::Migration[5.1]
  def change
    add_index :pay_scales, :label, unique: true
  end
end
