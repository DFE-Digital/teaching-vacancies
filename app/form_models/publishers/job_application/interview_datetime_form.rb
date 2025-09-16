class Publishers::JobApplication::InterviewDatetimeForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :interview_date, :date_or_hash
  # attribute :interview_time, :time_or_string
  attr_accessor :interview_time
  attr_accessor :job_application

  validates :interview_date, date: {}
  # validates :interview_time, time: {}
  validate :job_application_status
  validate :time_format

  def interviewing_at
    Time.zone.local(
      interview_date.year,
      interview_date.month,
      interview_date.day,
      parsed_time.hour,
      parsed_time.min,
    )
  end

  def parsed_time
    @parsed_time ||= Time.zone.parse(interview_time)
  end

  private

  def job_application_status
    errors.add(:job_application, :invalid) unless job_application.interviewing?
  end

  def time_format
    errors.add(:interview_time, :blank) unless parsed_time
  rescue ArgumentError, TypeError
    errors.add(:interview_time, :invalid)
  end
end
