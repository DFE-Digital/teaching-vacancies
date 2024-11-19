class AddInterviewingAtToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :interviewing_at, :datetime
  end
end
