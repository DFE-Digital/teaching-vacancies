class Publishers::JobListing::ImportantDatesForm < Publishers::JobListing::VacancyForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :expiry_time
  attr_reader :expires_at, :publish_on
  attr_writer :publish_on_day

  validates(:publish_on, date: { on_or_after: :today, on_or_before: :far_future }, unless: lambda do
    publish_on_day.blank? || disable_editing_publish_on? || (publish_on.is_a?(Date) && (publish_on.today? || publish_on.tomorrow?))
  end)
  validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }, unless: :disable_editing_publish_on?
  validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :publish_on }
  validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }

  def self.fields
    %i[publish_on expires_at]
  end

  def self.optional?
    form_section = new({}, Vacancy.new)
    form_section.skip_after_validation_big_query_callback = true
    form_section.valid?
  end

  def initialize(params, vacancy, current_publisher = nil)
    @expiry_time = params[:expiry_time] || vacancy.expires_at&.strftime("%k:%M")&.strip

    super(params, vacancy, current_publisher)
  end

  def disable_editing_publish_on?
    vacancy.published? && (vacancy.publish_on.past? || vacancy.publish_on.today?)
  end

  def params_to_save
    {
      completed_steps: completed_steps,
      publish_on: publish_on,
      expires_at: expires_at,
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
end
