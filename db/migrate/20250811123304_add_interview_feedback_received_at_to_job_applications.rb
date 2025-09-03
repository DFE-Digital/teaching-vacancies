class AddInterviewFeedbackReceivedAtToJobApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :interview_feedback_received_at, :datetime
    add_column :job_applications, :interview_feedback_received, :boolean # rubocop:disable Rails/ThreeStateBooleanColumn
  end
end
