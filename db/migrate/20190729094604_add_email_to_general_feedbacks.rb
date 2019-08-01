class AddEmailToGeneralFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :general_feedbacks, :email, :string
  end
end
