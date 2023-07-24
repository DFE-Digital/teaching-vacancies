class AddPublishersIdFeedbacksPublisherIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :feedbacks, :publishers, column: :publisher_id, primary_key: :id, validate: false
    validate_foreign_key :feedbacks, :publishers
  end
end
