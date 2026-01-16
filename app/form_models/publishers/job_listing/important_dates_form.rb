class Publishers::JobListing::ImportantDatesForm < Publishers::JobListing::ExpiryDateTimeForm
  attr_writer :publish_on_day
  attr_reader :publish_on

  #  ;publish_on_day is a radio, so this validation is skipped if it hasn't been selected
  validates :publish_on, date: { on_or_after: :today, on_or_before: :far_future }, unless: -> { publish_on_day.blank? }
  validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }

  def self.fields
    %i[publish_on expires_at]
  end

  def params_to_save
    { expires_at: expires_at,
      publish_on: publish_on }
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
