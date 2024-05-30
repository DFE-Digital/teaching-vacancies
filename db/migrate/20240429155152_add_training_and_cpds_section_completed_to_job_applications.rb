class AddTrainingAndCpdsSectionCompletedToJobApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :training_and_cpds_section_completed, :boolean
  end
end
