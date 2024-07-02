class AddImportedStepsToJobApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :imported_steps, :integer, default: [], null: false, array: true
  end
end
