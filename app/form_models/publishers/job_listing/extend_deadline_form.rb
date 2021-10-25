class Publishers::JobListing::ExtendDeadlineForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :expiry_time, :starts_asap, :previous_deadline
  attr_reader :expires_at, :starts_on

  validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :previous_deadline }
  validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }
  validates :starts_on, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, allow_blank: true,
                        if: proc { starts_asap == "0" }
  validate :starts_on_and_starts_asap_not_present

  def attributes_to_save
    { expires_at: expires_at, starts_on: (starts_on unless starts_asap == "true"), starts_asap: starts_asap }
  end

  def expires_at=(value)
    expires_on = date_from_multiparameter_hash(value)
    @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
  end

  def starts_on=(value)
    @starts_on = date_from_multiparameter_hash(value)
  end

  private

  def starts_on_and_starts_asap_not_present
    errors.add(:starts_on, :date_and_asap) if starts_on.present? && starts_asap == "true"
  end
end
