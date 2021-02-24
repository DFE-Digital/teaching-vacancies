class AddCompletedStepsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :completed_steps, :integer, array: true
  end
end
