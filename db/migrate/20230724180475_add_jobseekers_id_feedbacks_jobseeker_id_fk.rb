class AddJobseekersIdFeedbacksJobseekerIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :feedbacks, :jobseekers, column: :jobseeker_id, primary_key: :id, validate: false
    validate_foreign_key :feedbacks, :jobseekers
  end
end
