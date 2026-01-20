class AddOnlineChecksToJobApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :job_applications, :online_checks, :integer, default: 1, null: false
    add_column :job_applications, :online_checks_updated_at, :datetime
  end
end
