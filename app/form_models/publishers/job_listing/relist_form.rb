class Publishers::JobListing::RelistForm < Publishers::JobListing::ExtendDeadlineForm
  attr_reader :publish_on
  attr_writer :publish_on_day

  validates(:publish_on, date: { on_or_after: :today, on_or_before: :far_future }, unless: lambda do
    publish_on_day.blank? || (publish_on.is_a?(Date) && (publish_on.today? || publish_on.tomorrow?))
  end)
  validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }

  def initialize(params = {})
    @params = params
    super
  end

  def attributes_to_save
    super.merge(
      publish_on: publish_on,
    )
  end

  def publish_on_day
    return "today" if @publish_on_day == "today" || publish_on == Date.today
    return "tomorrow" if @publish_on_day == "tomorrow" || publish_on == Date.tomorrow

    "another_day" if @publish_on_day == "another_day" || publish_on.is_a?(Date)
  end

  def publish_on=(value)
    @publish_on =
      case @params[:publish_on_day]
      when "today" then Date.today
      when "tomorrow" then Date.tomorrow
      else date_from_multiparameter_hash(value)
      end
  end
end
