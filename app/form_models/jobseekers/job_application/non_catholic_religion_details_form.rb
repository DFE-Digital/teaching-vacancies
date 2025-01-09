class Jobseekers::JobApplication::NonCatholicReligionDetailsForm < Jobseekers::JobApplication::BaseForm
  def self.fields
    %i[faith
       place_of_worship
       religious_reference_type
       religious_referee_name
       religious_referee_address
       religious_referee_role
       religious_referee_email
       religious_referee_phone]
  end
  attr_accessor(*fields)

  validates :faith, presence: true
  validates :religious_reference_type, inclusion: { in: %w[referee no_referee], nil: false }

  validates :religious_referee_name, :religious_referee_address, :religious_referee_role, :religious_referee_email,
            presence: true, if: -> { religious_reference_type == "referee" }
  validates :religious_referee_email, email: true, if: -> { religious_reference_type == "referee" }
end
