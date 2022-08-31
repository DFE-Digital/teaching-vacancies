class Publishers::JobListing::ExtendDeadlineForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :expiry_time, :other_start_date_details, :start_date_type, :previous_deadline
  attr_reader :expires_at, :starts_on, :earliest_start_date, :latest_start_date

  validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :previous_deadline }
  validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }
  validates :start_date_type, inclusion: { in: Vacancy.start_date_types.keys }
  validates :starts_on, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, if: -> { start_date_type == "specific_date" }
  validates :earliest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at, before: :latest_start_date }, if: -> { start_date_type == "date_range" }
  validates :latest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :earliest_start_date }, if: -> { start_date_type == "date_range" }
  validates :other_start_date_details, presence: true, if: -> { start_date_type == "other" }

  def attributes_to_save
    {
      expires_at: expires_at,
      start_date_type: start_date_type,
      starts_on: (starts_on if start_date_type == "specific_date"),
      earliest_start_date: (earliest_start_date if start_date_type == "date_range"),
      latest_start_date: (latest_start_date if start_date_type == "date_range"),
      other_start_date_details: (other_start_date_details if start_date_type == "other"),
    }
  end

  def expires_at=(value)
    expires_on = date_from_multiparameter_hash(value)
    @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
  end

  def starts_on=(value)
    @starts_on = date_from_multiparameter_hash(value)
  end

  def earliest_start_date=(value)
    @earliest_start_date = date_from_multiparameter_hash(value)
  end

  def latest_start_date=(value)
    @latest_start_date = date_from_multiparameter_hash(value)
  end
end
