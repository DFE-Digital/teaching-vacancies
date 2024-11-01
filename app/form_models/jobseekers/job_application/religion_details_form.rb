class Jobseekers::JobApplication::ReligionDetailsForm < Jobseekers::JobApplication::BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  def self.fields
    %i[faith
       place_of_worship
       religious_reference_type
       religious_referee_name
       religious_referee_address
       religious_referee_role
       religious_referee_email
       religious_referee_phone
       baptism_certificate
       baptism_address
       baptism_date]
  end
  attr_accessor(*fields)

  validates :faith, presence: true
  validates :religious_reference_type, inclusion: { in: JobApplication::RELIGIOUS_REFERENCE_TYPES.keys.map(&:to_s), nil: false }

  validates :religious_referee_name, :religious_referee_address, :religious_referee_role, :religious_referee_email,
            presence: true, if: -> { religious_reference_type == "referee" }
  validates :religious_referee_email, email: true, if: -> { religious_reference_type == "referee" }

  validates :baptism_address, :baptism_date,
            presence: true, if: -> { religious_reference_type == "baptism_date" }

  validates :baptism_certificate, form_file: true, presence: true, if: -> { religious_reference_type == "baptism_certificate" }

  def file_type
    :document
  end

  def valid_file_types
    %i[PDF DOC DOCX]
  end

  def file_size_limit
    10.megabytes
  end

  def content_types_allowed
    %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze
  end
end
