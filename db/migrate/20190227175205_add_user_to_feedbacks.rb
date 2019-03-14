class AddUserToFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :feedbacks, :user_id, :uuid
    add_index :feedbacks, :user_id
  end
end
