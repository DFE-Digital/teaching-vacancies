class AddIndexToPayScale < ActiveRecord::Migration[5.1]
  def change
    add_column :pay_scales, :index, :integer
  end
end
