class Publishers::JobListing::StartDateForm < Publishers::JobListing::VacancyForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :other_start_date_details, :start_date_type
  attr_reader :starts_on, :earliest_start_date, :latest_start_date

  validates :start_date_type, inclusion: { in: Vacancy.start_date_types.keys }
  validates :starts_on, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, if: -> { start_date_type == "specific_date" }
  validates :earliest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at, before: :latest_start_date }, if: -> { start_date_type == "date_range" }
  validates :latest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :earliest_start_date }, if: -> { start_date_type == "date_range" }
  validates :other_start_date_details, presence: true, if: -> { start_date_type == "other" }

  def self.fields
    %i[start_date_type starts_on earliest_start_date latest_start_date other_start_date_details]
  end

  def self.optional?
    form_section = new({}, Vacancy.new)
    form_section.skip_after_validation_big_query_callback = true
    form_section.valid?
  end

  def params_to_save
    {
      start_date_type: start_date_type,
      starts_on: (starts_on if start_date_type == "specific_date"),
      earliest_start_date: (earliest_start_date if start_date_type == "date_range"),
      latest_start_date: (latest_start_date if start_date_type == "date_range"),
      other_start_date_details: (other_start_date_details if start_date_type == "other"),
    }
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

  def expires_at
    vacancy.expires_at
  end
end
