module Jobseekers
  module JobApplication
    class QualificationsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def unstorable_fields
          [:qualifications_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :qualifications)))
        end
      end

      attribute :qualifications_section_completed, :boolean
      validates :qualifications_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
