class AddJobApplicationIdToTrainingAndCpd < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :training_and_cpds, :job_application_id, :uuid
    add_index :training_and_cpds, :job_application_id, algorithm: :concurrently
    add_foreign_key :training_and_cpds, :job_applications, validate: false
    validate_foreign_key :training_and_cpds, :job_applications
  end
end
