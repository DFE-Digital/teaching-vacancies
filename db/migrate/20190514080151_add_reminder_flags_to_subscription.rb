class AddReminderFlagsToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :first_reminder_sent, :boolean, default: false
    add_column :subscriptions, :final_reminder_sent, :boolean, default: false
  end
end
