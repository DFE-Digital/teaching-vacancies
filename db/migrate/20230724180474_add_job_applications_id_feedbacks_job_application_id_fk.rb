class AddJobApplicationsIdFeedbacksJobApplicationIdFk < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_foreign_key :feedbacks, :job_applications, column: :job_application_id, primary_key: :id, validate: false
    validate_foreign_key :feedbacks, :job_applications
  end
end
