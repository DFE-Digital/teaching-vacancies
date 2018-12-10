class AddIndexToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_index :subscriptions, [:email, :status, :frequency, :expires_on], unique: true,
                              name: :subscription_email_status_frequency_expiry_index
    add_index :subscriptions, [:status, :frequency, :expires_on]
  end
end
