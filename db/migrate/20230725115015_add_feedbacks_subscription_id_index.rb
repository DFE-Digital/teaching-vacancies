class AddFeedbacksSubscriptionIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :feedbacks, ["subscription_id"], name: :index_feedbacks_subscription_id, algorithm: :concurrently
  end
end
