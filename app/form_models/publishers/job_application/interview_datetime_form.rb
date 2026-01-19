class Publishers::JobApplication::InterviewDatetimeForm
  # `InterviewDatetimeForm` operates on individual JobApplication instances only.
  # The form signature (job_applications) is consistent with other tag action form classes
  # in order for this class to participate in the same protocol.

  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :interview_date, :date_or_hash
  attribute :interview_time, :time_or_string

  attr_accessor :job_applications, :origin, :validate_all_attributes

  validates :interview_date, tvs_date: {}, if: -> { validate_all_attributes }
  validates :interview_time, time: {}, if: -> { validate_all_attributes }
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

  def attributes
    if validate_all_attributes && errors.empty?
      { interviewing_at: }
    else
      {}
    end
  end

  def name
    self.class.name.split("::").last
  end

  def job_application
    job_applications.first
  end

  private

  def job_application_status
    errors.add(:job_application, :invalid) unless job_application.interviewing?
  end
end
