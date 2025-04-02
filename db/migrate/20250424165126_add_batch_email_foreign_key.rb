class AddBatchEmailForeignKey < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :batch_email_job_applications, :batch_emails, validate: false
  end
end
