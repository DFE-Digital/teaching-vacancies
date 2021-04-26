class AddExportedToBigqueryToFeedback < ActiveRecord::Migration[6.1]
  def change
    add_column :feedbacks, :exported_to_bigquery, :boolean, default: false, null: false
  end
end
