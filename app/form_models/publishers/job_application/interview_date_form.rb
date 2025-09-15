class Publishers::JobApplication::InterviewDateForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :interviewing_at, :date_or_hash
  attr_accessor :job_application, :time

  validates :interviewing_at, date: {}, allow_nil: true
  validate :job_application_status
  validate :time_format

  def interviewing_datetime_at
    Time.zone.local(
      interviewing_at.year,
      interviewing_at.month,
      interviewing_at.day,
      parsed_time.hour,
      parsed_time.min,
    )
  end

  def parsed_time
    @parsed_time ||= Time.zone.parse(time)
  end

  private

  def job_application_status
    errors.add(:job_application, :invalid) unless job_application.interviewing?
  end

  def time_format
    parsed_time
  rescue ArgumentError, TypeError
    errors.add(:time, :invalid)
  end
end
