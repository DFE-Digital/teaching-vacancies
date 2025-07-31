class Publishers::JobApplication::ReferencesContactApplicantForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :collect_self_disclosure, :boolean
  attribute :collect_references, :boolean

  attribute :contact_applicants, :boolean
  validates :contact_applicants, inclusion: { in: [true, false], allow_nil: false }

  class << self
    def fields
      %i[contact_applicants collect_self_disclosure collect_references]
    end
  end
end
