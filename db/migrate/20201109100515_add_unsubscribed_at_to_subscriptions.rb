class AddUnsubscribedAtToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :unsubscribed_at, :datetime
  end
end
