module Jobseekers
  module JobApplication
    class ProfessionalBodyMembershipsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def unstorable_fields
          %i[professional_body_memberships_section_completed]
        end
        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :professional_body_memberships)))
        end
      end

      completed_attribute(:professional_body_memberships)
    end
  end
end
