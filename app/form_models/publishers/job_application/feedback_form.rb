class Publishers::JobApplication::FeedbackForm < Publishers::JobApplication::TagForm
  attribute :interview_feedback_received_at, :date_or_hash
  attribute :interview_feedback_received, :boolean

  validates :interview_feedback_received_at, date: {}, allow_nil: true
end
