module Jobseekers
  module JobApplication
    class DeclarationsForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[close_relationships close_relationships_details right_to_work_in_uk safeguarding_issue safeguarding_issue_details].freeze

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[declarations_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :declarations)))
        end
      end
      attr_accessor(*FIELDS)

      validates :close_relationships, inclusion: { in: %w[yes no] }, if: -> { declarations_section_completed }
      validates :close_relationships_details, presence: true, if: -> { close_relationships == "yes" && declarations_section_completed }
      validates :safeguarding_issue, inclusion: { in: %w[yes no] }, if: -> { declarations_section_completed }
      validates :safeguarding_issue_details, presence: true, if: -> { safeguarding_issue == "yes" && declarations_section_completed }

      completed_attribute(:declarations)
    end
  end
end
