class Publishers::JobListing::ImportantDatesForm < Publishers::JobListing::VacancyForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :expiry_time, :other_start_date_details, :start_date_type
  attr_reader :expires_at, :publish_on, :starts_on, :earliest_start_date, :latest_start_date
  attr_writer :publish_on_day

  validates(:publish_on, date: { on_or_after: :today, on_or_before: :far_future }, unless: lambda do
    publish_on_day.blank? || disable_editing_publish_on? || (publish_on.is_a?(Date) && (publish_on.today? || publish_on.tomorrow?))
  end)
  validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }, unless: :disable_editing_publish_on?
  validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :publish_on }
  validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }
  validates :start_date_type, inclusion: { in: Vacancy.start_date_types.keys }
  validates :starts_on, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, if: -> { start_date_type == "specific_date" }
  validates :earliest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at, before: :latest_start_date }, if: -> { start_date_type == "date_range" }
  validates :latest_start_date, presence: true, date: { on_or_after: :today, on_or_before: :far_future, after: :earliest_start_date }, if: -> { start_date_type == "date_range" }
  validates :other_start_date_details, presence: true, if: -> { start_date_type == "other" }

  def self.fields
    %i[start_date_type starts_on earliest_start_date latest_start_date other_start_date_details publish_on expires_at]
  end

  def self.optional?
    form_section = new({}, Vacancy.new)
    form_section.skip_after_validation_big_query_callback = true
    form_section.valid?
  end

  def initialize(params, vacancy)
    @expiry_time = params[:expiry_time] || vacancy.expires_at&.strftime("%k:%M")&.strip

    super(params, vacancy)
  end

  def disable_editing_publish_on?
    vacancy.published? && (vacancy.publish_on.past? || vacancy.publish_on.today?)
  end

  def params_to_save
    {
      completed_steps: completed_steps,
      publish_on: publish_on,
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

  def publish_on_day
    return "today" if params[:publish_on_day] == "today" || params[:publish_on] == Date.today
    return "tomorrow" if params[:publish_on_day] == "tomorrow" || params[:publish_on] == Date.tomorrow

    "another_day" if params[:publish_on_day] == "another_day" || params[:publish_on].is_a?(Date)
  end

  def publish_on=(value)
    @publish_on =
      case params[:publish_on_day]
      when "today" then Date.today
      when "tomorrow" then Date.tomorrow
      else date_from_multiparameter_hash(value)
      end
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
