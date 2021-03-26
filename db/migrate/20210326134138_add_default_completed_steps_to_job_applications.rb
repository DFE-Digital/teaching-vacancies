class AddDefaultCompletedStepsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    change_column_default :job_applications, :completed_steps, []
    change_column_null :job_applications, :completed_steps, false, []
  end
end
