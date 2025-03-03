module Jobseekers
  module JobApplication
    class AskForSupportForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def storable_fields
          %i[support_needed_details is_support_needed]
        end

        def unstorable_fields
          %i[ask_for_support_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :ask_for_support))
        end
      end
      attr_accessor(:support_needed_details)

      attribute :is_support_needed, :boolean

      validates :is_support_needed, inclusion: { in: [true, false] }, if: -> { ask_for_support_section_completed }
      validates :support_needed_details, presence: true, if: -> { is_support_needed && ask_for_support_section_completed }

      completed_attribute(:ask_for_support)
    end
  end
end
