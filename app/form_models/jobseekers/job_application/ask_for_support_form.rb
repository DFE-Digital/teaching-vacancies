module Jobseekers
  module JobApplication
    class AskForSupportForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[support_needed support_needed_details].freeze

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[ask_for_support_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :ask_for_support))
        end
      end
      attr_accessor(*FIELDS)

      validates :support_needed, inclusion: { in: %w[yes no] }, if: -> { ask_for_support_section_completed }
      validates :support_needed_details, presence: true, if: -> { support_needed == "yes" && ask_for_support_section_completed }

      completed_attribute(:ask_for_support)
    end
  end
end
