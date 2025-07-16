class Publishers::JobApplication::CollectReferencesForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :collect_references_and_self_disclosure, :boolean
  validates :collect_references_and_self_disclosure, inclusion: { in: [true, false], allow_nil: false }

  class << self
    def fields
      [:collect_references_and_self_disclosure]
    end
  end
end
