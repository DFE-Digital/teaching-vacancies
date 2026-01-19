class Publishers::JobListing::RelistForm < Publishers::JobListing::ImportantDatesForm
  # include ActiveRecord::AttributeAssignment
  # include DateAttributeAssignment

  # attr_reader :publish_on, :expires_at
  # attr_writer :publish_on_day

  # validates(:publish_on, date: { on_or_after: :today, on_or_before: :far_future }, unless: lambda do
  #   publish_on_day.blank? || (publish_on.is_a?(Date) && (publish_on.today? || publish_on.tomorrow?))
  # end)
  # validates :publish_on_day, inclusion: { in: %w[today tomorrow another_day] }

  # attr_accessor :expiry_time, :extension_reason, :other_extension_reason_details
  attr_accessor :extension_reason, :other_extension_reason_details

  # validates :expires_at, date: { on_or_after: :now, on_or_before: :far_future }
  # validates :expiry_time, inclusion: { in: Vacancy::EXPIRY_TIME_OPTIONS }

  validates :extension_reason, inclusion: { in: Vacancy.extension_reasons.keys }

  # def initialize(params = {})
  #   @params = params
  #   super
  # end

  def attributes_to_save
    {
      publish_on: publish_on,
      expires_at: expires_at,
      extension_reason: extension_reason,
      other_extension_reason_details: other_extension_reason_details,
    }
  end

  # def expires_at=(value)
  #   expires_on = date_from_multiparameter_hash(value)
  #   @expires_at = datetime_from_date_and_time(expires_on, expiry_time)
  # end

  # def publish_on_day
  #   return "today" if @publish_on_day == "today" || publish_on == Date.today
  #   return "tomorrow" if @publish_on_day == "tomorrow" || publish_on == Date.tomorrow
  #
  #   "another_day" if @publish_on_day == "another_day" || publish_on.is_a?(Date)
  # end

  # def publish_on=(value)
  #   @publish_on =
  #     case @params[:publish_on_day]
  #     when "today" then Date.today
  #     when "tomorrow" then Date.tomorrow
  #     else date_from_multiparameter_hash(value)
  #     end
  # end
end
