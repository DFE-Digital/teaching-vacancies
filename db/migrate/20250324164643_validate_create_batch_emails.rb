class ValidateCreateBatchEmails < ActiveRecord::Migration[7.2]
  def change
    validate_foreign_key :batch_emails, :vacancies
  end
end
