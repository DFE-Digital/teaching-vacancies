class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :status, :string
  attribute :offered_at, :date_or_hash
  attribute :declined_at, :date_or_hash
  attr_accessor :job_applications, :origin, :validate_status

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, if: -> { validate_status }
  validates_inclusion_of :status, in: JobApplication.statuses.except("draft").keys, if: -> { status.present? }
  validates :offered_at, date: {}, allow_nil: true
  validates :declined_at, date: {}, allow_nil: true

  def attributes
    return super.except("declined_at") if status == "offered"
    return super.except("offered_at") if status == "declined"

    super.except("declined_at", "offered_at")
  end
end
