class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :status, :string
  attribute :offered_at, :date_or_hash
  attribute :declined_at, :date_or_hash
  attribute :interview_feedback_received_at, :date_or_hash
  attr_accessor :job_applications, :origin, :validate_status

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, if: -> { validate_status }
  validates_inclusion_of :status, in: JobApplication.statuses.except("draft").keys, if: -> { status.present? }
  validates :offered_at, date: {}, allow_nil: true
  validates :declined_at, date: {}, allow_nil: true
  validates :interview_feedback_received_at, date: {}, allow_nil: true

  def interview_feedback_received
    return nil if interview_feedback_received_at.blank?

    interview_feedback_received_at.present?
  end

  def attributes
    super.except(*unnecessary_fields)
  end

  private

  # lists fields that are not necessary for certain statuses
  def unnecessary_fields
    return %w[declined_at interview_feedback_received_at] if status == "offered"
    return %w[offered_at interview_feedback_received_at] if status == "declined"
    return %w[declined_at offered_at] if status == "unsuccessful_interview"

    %w[declined_at offered_at interview_feedback_received_at]
  end
end
