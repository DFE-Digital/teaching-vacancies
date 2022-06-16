class AddInProgressStepsAndConfirmationsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :in_progress_steps, :integer, array: true, default: [], null: false
    add_column :job_applications, :employment_history_section_completed, :boolean
    add_column :job_applications, :qualifications_section_completed, :boolean
  end
end
