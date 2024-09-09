class AddJobFoundUnsubscribeReasonCommentToFeedback < ActiveRecord::Migration[7.1]
  def change
    add_column :feedbacks, :job_found_unsubscribe_reason_comment, :text
  end
end
