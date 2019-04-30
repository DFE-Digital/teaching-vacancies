class RemoveEmailFromGeneralFeedbacks < ActiveRecord::Migration[5.2]
  def change
    remove_column :general_feedbacks, :email, :string
  end
end
