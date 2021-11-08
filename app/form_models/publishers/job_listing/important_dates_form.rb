class Publishers::JobListing::ImportantDatesForm < Publishers::JobListing::VacancyForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :expiry_time, :starts_asap
  attr_reader :expires_at, :publish_on, :starts_on
  attr_writer :publish_on_day

  validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }, unless: :disable_editing_publish_on?
  validates :publish_on, date: { on_or_after: :today, on_or_before: :far_future }, if: proc { !disable_editing_publish_on? && publish_on_day == "another_day" }
  validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future, after: :publish_on }
  validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }
  validates :starts_on, date: { on_or_after: :today, on_or_before: :far_future, after: :expires_at }, allow_blank: true,
                        if: proc { ["true", "1"].include?(starts_asap) }
  validate :starts_on_and_starts_asap_not_present

  def self.fields
    %i[starts_asap starts_on publish_on expires_at]
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
      starts_on: (starts_on unless starts_asap == "true"),
      starts_asap: starts_asap,
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

  private

  def starts_on_and_starts_asap_not_present
    errors.add(:starts_on, :date_and_asap) if starts_on.present? && ["true", "1"].include?(starts_asap)
  end
end
