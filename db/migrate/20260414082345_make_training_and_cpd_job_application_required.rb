class MakeTrainingAndCpdJobApplicationRequired < ActiveRecord::Migration[8.0]
  def change
    change_column_null :training_and_cpds, :job_application_id, false
  end
end
