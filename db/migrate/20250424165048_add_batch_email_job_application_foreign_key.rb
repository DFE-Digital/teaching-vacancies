class AddBatchEmailJobApplicationForeignKey < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :batch_email_job_applications, :job_applications, validate: false
  end
end
