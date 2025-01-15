module Jobseekers
  module JobApplication
    class ReferencesForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def unstorable_fields
          %i[references_section_completed references]
        end

        def optional?
          false
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(references: model.references).merge(completed_attrs(model, :references)))
        end
      end

      attribute :references
      validates :references, length: { minimum: 2 }, if: -> { references_section_completed }

      completed_attribute(:references)
    end
  end
end
