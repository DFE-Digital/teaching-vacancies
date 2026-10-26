class Publishers::JobListing::StartDateForm < Publishers::JobListing::JobListingForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :other_start_date_details, :start_date_type, :expires_at
  attr_reader :starts_on, :earliest_start_date, :latest_start_date

  def self.fields
    %i[start_date_type starts_on earliest_start_date latest_start_date other_start_date_details expires_at]
  end

  # rubocop:disable Lint/UnusedMethodArgument
  def self.load_from_params(form_params, vacancy, current_publisher:)
    new(form_params.merge(expires_at: vacancy.expires_at))
  end
  # rubocop:enable Lint/UnusedMethodArgument

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
end
