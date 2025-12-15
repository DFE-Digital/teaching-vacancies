class RemovePersonalStatementCiphertextFromJobApplications < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :job_applications, :personal_statement_ciphertext, :text }
  end
end
