class AddLocationGeometryToSubscriptions < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :subscriptions, :area, :geometry, geographic: false
    add_column :subscriptions, :geopoint, :geometry, geographic: false
    add_column :subscriptions, :radius_in_metres, :integer
    add_index :subscriptions, :area, using: :gist, algorithm: :concurrently
    add_index :subscriptions, :geopoint, using: :gist, algorithm: :concurrently
  end
end
