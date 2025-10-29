class Publishers::JobApplication::DeclinedForm < Publishers::JobApplication::TagForm
  attribute :declined_at, :date_or_hash

  validates :declined_at, date: {}, allow_nil: true
  validate :declined_date_after_offered_dates

  private

  def declined_date_after_offered_dates
    return if declined_at.blank?

    # Check respond_to?(:to_date) because offered_at can be a Hash when date is invalid
    if job_applications.any? { |ja| ja.offered_at.present? && ja.offered_at.respond_to?(:to_date) && declined_at.to_date < ja.offered_at.to_date }
      errors.add(:declined_at, :must_be_after_offered_date)
    end
  end
end
