class Publishers::JobApplication::OfferDeclineDateForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :offered_at, :date_or_hash
  attribute :declined_at, :date_or_hash
  attribute :status, :string

  attr_accessor :job_applications, :origin

  validates :offered_at, date: {}, allow_nil: true
  validates :declined_at, date: {}, allow_nil: true
  validates_length_of :job_applications, minimum: 1

  def job_application_ids
    return [] if job_applications.blank?

    job_applications.pluck(:id)
  end

  def attributes
    hsh = super
    ignore_field = status == "offered" ? "declined_at" : "offered_at"
    hsh.delete(ignore_field)
    hsh
  end

  def self.fields
    [:origin, :status, { job_applications: [] }]
  end
end
