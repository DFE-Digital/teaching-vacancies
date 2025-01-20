module Jobseekers
  module JobApplication
    class PersonalStatementForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[personal_statement].freeze

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[personal_statement_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :personal_statement)))
        end
      end
      attr_accessor(*FIELDS)

      validates :personal_statement, presence: true, if: -> { personal_statement_section_completed }

      completed_attribute(:personal_statement)
    end
  end
end
