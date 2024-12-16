module Jobseekers
  module JobApplication
    class EmploymentHistoryForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[unexplained_employment_gaps_present].freeze

      class << self
        def storable_fields
          []
        end

        def unstorable_fields
          %i[unexplained_employment_gaps_present employment_history_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :employment_history)))
        end
      end
      attr_accessor(*FIELDS)

      validate :employment_history_does_not_contain_gaps

      def employment_history_does_not_contain_gaps
        return unless unexplained_employment_gaps_present == "true" && employment_history_section_completed

        errors.add(:employment_history_section_completed, "You must provide your full work history, including the reason for any gaps in employment.")
      end

      attribute :employment_history_section_completed, :boolean
      validates :employment_history_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
