module Jobseekers
  module JobApplication
    class ProfessionalStatusForm < BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include CompletedFormAttribute

      FIELDS = %i[
        qualified_teacher_status
        qualified_teacher_status_year
        qualified_teacher_status_details
        statutory_induction_complete
        teacher_reference_number
        statutory_induction_complete_details
        qts_age_range_and_subject
      ].freeze

      attr_accessor(*FIELDS, :has_teacher_reference_number)

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[has_teacher_reference_number professional_status_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :professional_status))
               .merge(has_teacher_reference_number: model[:teacher_reference_number].present? ? "yes" : "no")
        end
      end

      def initialize(attributes = {})
        jobseeker_profile = attributes.delete(:jobseeker_profile)
        super

        if attributes[:statutory_induction_complete] == "yes"
          self.statutory_induction_complete_details = nil
        end
        return unless jobseeker_profile

        self.teacher_reference_number ||= jobseeker_profile.teacher_reference_number
        self.has_teacher_reference_number ||= jobseeker_profile.has_teacher_reference_number
      end

      # These validations are only applied when the professional status section is marked as completed.
      #
      # Equivalent to if: -> { professional_status_section_completed == true }.
      # Nested validations using "if" calls would override the parent "with_options if:" call instead of combining the conditions.
      # By using "unless" we can keep using "if" for nested validations and the "if & unless" conditions will be combined.
      with_options unless: -> { professional_status_section_completed != true } do
        validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }
        validates :statutory_induction_complete, inclusion: { in: %w[yes no] }

        with_options if: -> { qualified_teacher_status == "yes" } do
          validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } }
          validates :has_teacher_reference_number, inclusion: { in: %w[yes] }
        end

        with_options if: -> { qualified_teacher_status.in?(%w[no on_track]) } do
          validates :has_teacher_reference_number, inclusion: { in: %w[yes no] }
        end
      end

      # Teacher reference number:
      # Its presence is required when the "has_teacher_reference_number" is "yes".
      # Its format is validated only when the number is provided.
      validates :teacher_reference_number, presence: true, if: -> { has_teacher_reference_number == "yes" }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true

      completed_attribute(:professional_status)
    end
  end
end
