class AddFeedbacksJobApplicationIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :feedbacks, ["job_application_id"], name: :index_feedbacks_job_application_id, algorithm: :concurrently
  end
end
