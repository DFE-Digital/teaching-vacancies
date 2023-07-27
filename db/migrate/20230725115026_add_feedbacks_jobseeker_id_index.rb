class AddFeedbacksJobseekerIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :feedbacks, ["jobseeker_id"], name: :index_feedbacks_jobseeker_id, algorithm: :concurrently
  end
end
