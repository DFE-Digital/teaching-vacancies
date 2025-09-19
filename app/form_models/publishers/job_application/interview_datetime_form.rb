class Publishers::JobApplication::InterviewDatetimeForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :interview_date, :date_or_hash
  attribute :interview_time, :time_or_string

  attr_accessor :job_application

  validates :interview_date, date: {}
  validates :interview_time, time: {}
  validate :job_application_status

  def interviewing_at
    Time.zone.local(
      interview_date.year,
      interview_date.month,
      interview_date.day,
      interview_time.hour,
      interview_time.min,
    )
  rescue StandardError
    raise ArgumentError, "invalid interview_date or interview_time"
  end

  private

  def job_application_status
    errors.add(:job_application, :invalid) unless job_application.interviewing?
  end
end
