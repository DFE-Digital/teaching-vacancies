class AddApplicationIdToFeedbacks < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :application_id, :uuid
  end
end
