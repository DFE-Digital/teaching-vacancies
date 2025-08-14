class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :status, :string
  attr_accessor :job_applications, :origin, :validate_status

  validates_length_of :job_applications, minimum: 1
  validates_presence_of :status, if: -> { validate_status }
  validates_inclusion_of :status, in: JobApplication.statuses.except("draft").keys, if: -> { status.present? }

  def name
    self.class.name.split("::").last
  end
end
