class AddWorkingPatternsToJobApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :working_patterns, :integer, array: true
    add_column :job_applications, :working_pattern_details, :string
  end
end
