class Publishers::JobApplication::FeedbackForm < Publishers::JobApplication::TagForm
  attribute :interview_feedback_received_at, :date_or_hash
  attribute :interview_feedback_received, :boolean

  validates :interview_feedback_received_at, tvs_date: {}, allow_nil: true
  validate :feedback_date_after_interview_dates, if: -> { interview_feedback_received_at.respond_to?(:to_date) && interview_feedback_received }

  private

  def feedback_date_after_interview_dates
    if job_applications.any? { |ja| ja.interviewing_at.present? && interview_feedback_received_at.to_date < ja.interviewing_at.to_date }
      errors.add(:interview_feedback_received_at, :must_be_after_interview_date)
    end
  end
end
