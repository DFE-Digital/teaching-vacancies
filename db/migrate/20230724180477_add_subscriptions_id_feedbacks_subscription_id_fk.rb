class AddSubscriptionsIdFeedbacksSubscriptionIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :feedbacks, :subscriptions, column: :subscription_id, primary_key: :id, validate: false
    validate_foreign_key :feedbacks, :subscriptions
  end
end
