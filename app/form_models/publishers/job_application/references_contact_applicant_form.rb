class Publishers::JobApplication::ReferencesContactApplicantForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :contact_applicants, :boolean
  validates :contact_applicants, inclusion: { in: [true, false], allow_nil: false }

  class << self
    def fields
      [:contact_applicants]
    end
  end
end
