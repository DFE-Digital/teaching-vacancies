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
          super.merge(completed_attrs(model, :qualifications))
        end
      end

      completed_attribute(:qualifications)
    end
  end
end
