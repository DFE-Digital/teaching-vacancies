class AddDSIDataToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :dsi_data, :jsonb
  end
end
