class ChangeFeedbacksAndGeneralFeedbacksCommentFieldTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :feedbacks, :comment, :text

    change_column :general_feedbacks, :comment, :text
    change_column :general_feedbacks, :visit_purpose_comment, :text
  end
end
