class ValidateAddBatchEmailForeignKey < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :batch_email_job_applications, :batch_emails
  end
end
