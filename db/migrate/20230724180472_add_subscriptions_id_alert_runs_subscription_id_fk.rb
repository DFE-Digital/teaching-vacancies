class AddSubscriptionsIdAlertRunsSubscriptionIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :alert_runs, :subscriptions, column: :subscription_id, primary_key: :id, validate: false
    validate_foreign_key :alert_runs, :subscriptions
  end
end
