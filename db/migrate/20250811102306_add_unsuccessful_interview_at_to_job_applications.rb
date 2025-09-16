class AddUnsuccessfulInterviewAtToJobApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :unsuccessful_interview_at, :datetime
  end
end
