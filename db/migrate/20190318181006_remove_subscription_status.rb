class RemoveSubscriptionStatus < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :status
  end
end
