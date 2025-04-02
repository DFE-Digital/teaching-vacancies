class ValidateAddBatchEmailJobApplicationForeignKey < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :batch_email_job_applications, :job_applications
  end
end
