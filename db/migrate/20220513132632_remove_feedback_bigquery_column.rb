class RemoveFeedbackBigqueryColumn < ActiveRecord::Migration[6.1]
  def change
    remove_column :feedbacks, :exported_to_bigquery, :boolean, default: false, null: false
  end
end
