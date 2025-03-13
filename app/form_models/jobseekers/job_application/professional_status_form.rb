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
        teacher_reference_number
        statutory_induction_complete_details
        qts_age_range_and_subject
      ].freeze

      attr_accessor(*FIELDS, :has_teacher_reference_number)

      class << self
        def storable_fields
          FIELDS + [:is_statutory_induction_complete]
        end

        def unstorable_fields
          %i[has_teacher_reference_number professional_status_section_completed]
        end

        def load_form(model)
          super.merge(completed_attrs(model, :professional_status))
               .merge(has_teacher_reference_number: model[:teacher_reference_number].present? ? "yes" : "no")
        end
      end

      attribute :is_statutory_induction_complete, :boolean

      def initialize(attributes = {})
        super

        if attributes[:is_statutory_induction_complete] == true
          self.statutory_induction_complete_details = nil
        end
      end

      # These validations are only applied when the professional status section is marked as completed.
      #
      # Nested validations using "if" calls would override the parent "with_options if:" call instead of combining the conditions.
      # By using "unless" we can keep using "if" for nested validations and the "if & unless" conditions will be combined.
      #
      # BAD: Output would be "validates ... if: -> { condition B }".
      # with_options if: -> { condition A }
      #   validates ... if: -> { condition B }
      # end
      #
      # GOOD: Output would be "validates ... unless: -> { !condition A }, if: -> { condition B }".
      #       That is the same as "validates ... if: -> { condition A && condition B }".
      # with_options unless: -> { !condition A }
      #   validates ... if: -> { condition B }
      # end
      #
      # Equivalent to if: -> { professional_status_section_completed == true }.
      with_options unless: -> { professional_status_section_completed != true } do
        validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }
        validates :is_statutory_induction_complete, inclusion: { in: [true, false] }

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
      # Having a qualified teacher status 'yes' will enforce the "has_teacher_reference_number" to be 'yes' what will force
      # the "teacher_reference_number" to be present and formatted correctly.
      # Codewise "has_teacher_reference_number" seems to be a redundant field as it can be inferred from the presence
      # of the "teacher_reference_number".
      validates :teacher_reference_number, presence: true, if: -> { has_teacher_reference_number == "yes" }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true

      completed_attribute(:professional_status)
    end
  end
end
