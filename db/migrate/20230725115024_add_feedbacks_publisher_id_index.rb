class AddFeedbacksPublisherIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :feedbacks, ["publisher_id"], name: :index_feedbacks_publisher_id, algorithm: :concurrently
  end
end
