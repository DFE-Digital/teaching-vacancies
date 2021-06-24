class RemoveApplicationIdFromFeedbacks < ActiveRecord::Migration[6.1]
  def change
    remove_column :feedbacks, :application_id, :uuid
  end
end
