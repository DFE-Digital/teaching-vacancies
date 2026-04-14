class MakeTrainingAndCpdJobApplicationRequired < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_not_null_constraint :training_and_cpds, :job_application_id, name: "training_and_cpds_job_application_id_null", validate: false
    validate_not_null_constraint :training_and_cpds, :job_application_id, name: "training_and_cpds_job_application_id_null"
    change_column_null :training_and_cpds, :job_application_id, false
    remove_check_constraint :training_and_cpds, name: "training_and_cpds_job_application_id_null"
  end
end
