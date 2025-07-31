class Publishers::JobApplication::CollectReferencesForm
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Attributes

  attribute :collect_references, :boolean
  validates :collect_references, inclusion: { in: [true, false], allow_nil: false }

  class << self
    def fields
      [:collect_references]
    end
  end
end
