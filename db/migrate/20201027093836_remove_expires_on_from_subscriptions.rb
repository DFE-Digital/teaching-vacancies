class RemoveExpiresOnFromSubscriptions < ActiveRecord::Migration[6.0]
  def change
    remove_column :subscriptions, :expires_on
  end
end
