class ChangeSubscriptionUkAreaType < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :subscriptions, :new_uk_area, :geometry, srid: 27_700
    add_index :subscriptions, :new_uk_area, using: :gist, algorithm: :concurrently
    remove_index :subscriptions, name: :index_subscriptions_on_uk_area, algorithm: :concurrently
    safety_assured do
      remove_column :subscriptions, :uk_area
      rename_column :subscriptions, :new_uk_area, :uk_area
    end
  end
end
