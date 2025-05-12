class Publishers::JobApplication::CollectReferencesForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  # attr_accessor :job_applications

  attribute :collect_references_and_declarations, :boolean
  validates :collect_references_and_declarations, inclusion: { in: [true, false], allow_nil: false }

  class << self
    def fields
      [:collect_references_and_declarations]
    end
  end
end
