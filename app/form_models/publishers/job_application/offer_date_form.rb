class Publishers::JobApplication::OfferDateForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment

  attribute :offered_at, :date_or_hash
  attribute :declined_at, :date_or_hash
  attribute :status, :string
  attr_accessor :origin
  attr_reader :job_applications

  validates :offered_at, date: {}, allow_nil: true
  validates :declined_at, date: {}, allow_nil: true
  validates_length_of :job_applications, minimum: 1

  def job_applications=(value)
    @job_applications = value.count == 1 ? value[0].split : value
  end

  def attributes
    hsh = super
    ignore_field = status == "offered" ? "declined_at" : "offered_at"
    hsh.delete(ignore_field)
    hsh
  end
end
