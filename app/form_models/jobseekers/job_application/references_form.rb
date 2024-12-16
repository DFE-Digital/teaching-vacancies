module Jobseekers
  module JobApplication
    class ReferencesForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def fields
          [:references_section_completed]
        end

        def unstorable_fields
          %i[references_section_completed]
        end

        def optional?
          false
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :references)))
        end
      end

      attribute :references_section_completed, :boolean

      validates :references_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
