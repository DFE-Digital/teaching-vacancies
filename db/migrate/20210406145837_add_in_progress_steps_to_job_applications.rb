class AddInProgressStepsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :in_progress_steps, :integer, array: true, default: [], null: false
  end
end
