class AddGiasDataHashToOrganisations < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :gias_data_hash, :text, null: true
  end
end
