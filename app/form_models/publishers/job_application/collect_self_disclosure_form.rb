module Publishers
  module JobApplication
    class CollectSelfDisclosureForm
      include ActiveModel::Model
      include ActiveModel::Validations
      include ActiveModel::Attributes

      attribute :collect_references, :boolean
      attribute :contact_applicants, :boolean

      attribute :collect_self_disclosure, :boolean
      validates :collect_self_disclosure, inclusion: { in: [true, false], allow_nil: false }

      class << self
        def fields
          %i[collect_self_disclosure contact_applicants collect_references]
        end
      end
    end
  end
end
