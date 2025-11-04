class Publishers::JobApplication::DeclinedForm < Publishers::JobApplication::TagForm
  attribute :declined_at, :date_or_hash

  validates :declined_at, date: {}, allow_nil: true
  validate :declined_date_after_offered_dates, if: -> { declined_at.respond_to?(:to_date) }

  private

  def declined_date_after_offered_dates
    if job_applications.any? { |ja| ja.offered_at.present? && declined_at.to_date < ja.offered_at.to_date }
      errors.add(:declined_at, :must_be_after_offered_date)
    end
  end
end
