class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  VALID_STATUSES = %w[submitted unsuccessful reviewed shortlisted interviewing].freeze

  attribute :status, :string
  attr_accessor :job_applications, :origin, :validate_status

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, if: -> { validate_status }
  validates_inclusion_of :status, in: VALID_STATUSES, if: -> { status.present? }
end
