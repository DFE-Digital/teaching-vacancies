class Publishers::JobApplication::OfferedForm < Publishers::JobApplication::TagForm
  attribute :offered_at, :date_or_hash

  validates :offered_at, date: {}, allow_nil: true
  validate :offered_date_after_interview_dates

  private

  def offered_date_after_interview_dates
    return if offered_at.blank?

    if job_applications.any? { |ja| offered_at.to_date < ja.interviewing_at.to_date }
      errors.add(:offered_at, :must_be_after_interview_date)
    end
  end
end
