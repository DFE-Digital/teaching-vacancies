class RemoveDSIDataFromPublishers < ActiveRecord::Migration[6.1]
  def change
    remove_column :publishers, :dsi_data, :jsonb
  end
end
