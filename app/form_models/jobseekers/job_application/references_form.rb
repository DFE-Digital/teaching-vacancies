module Jobseekers
  module JobApplication
    class ReferencesForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
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

      completed_attribute(:references)
    end
  end
end
