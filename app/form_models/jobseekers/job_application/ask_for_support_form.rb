module Jobseekers
  module JobApplication
    class AskForSupportForm < Jobseekers::JobApplication::BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[support_needed support_needed_details].freeze

      class << self
        def fields
          FIELDS + [:ask_for_support_section_completed]
        end

        def unstorable_fields
          %i[ask_for_support_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :ask_for_support)))
        end
      end
      attr_accessor(*FIELDS)

      validates :support_needed, inclusion: { in: %w[yes no] }
      validates :support_needed_details, presence: true, if: -> { support_needed == "yes" }

      attribute :ask_for_support_section_completed, :boolean

      validates :ask_for_support_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
