class AddSubmittedAtToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :submitted_at, :datetime
  end
end
