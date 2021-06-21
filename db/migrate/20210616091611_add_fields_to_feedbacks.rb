class AddFieldsToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :close_account_reason, :integer
    add_column :feedbacks, :close_account_reason_comment, :text
  end
end
