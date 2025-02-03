class AddWorkingPatternDetailsToJobPreferences < ActiveRecord::Migration[7.2]
  def change
    add_column :job_preferences, :working_pattern_details, :string
  end
end
