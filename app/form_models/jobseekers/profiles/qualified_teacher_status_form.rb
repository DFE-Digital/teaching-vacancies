module Jobseekers
  module Profiles
    class QualifiedTeacherStatusForm < BaseForm
      include ActiveModel::Attributes

      validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track non_teacher] }
      validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } }, if: -> { qualified_teacher_status == "yes" }
      validates :teacher_reference_number, presence: true, if: -> { qualified_teacher_status == "yes" }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: false, if: -> { qualified_teacher_status == "yes" || has_teacher_reference_number == "yes" }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true, if: -> { %w[no on_track].include?(qualified_teacher_status) }
      validates :is_statutory_induction_complete, inclusion: { in: [true, false] }, if: -> { qualified_teacher_status == "yes" }

      validates :has_teacher_reference_number, inclusion: { in: %w[yes] }, if: -> { qualified_teacher_status == "yes" }
      validates :has_teacher_reference_number, inclusion: { in: %w[yes no] }, if: -> { %w[no on_track].include?(qualified_teacher_status) }

      def initialize(attributes = {})
        super

        if attributes[:is_statutory_induction_complete]
          self.statutory_induction_complete_details = nil
        end
      end

      FIELDS = %i[qualified_teacher_status
                  qualified_teacher_status_year
                  teacher_reference_number
                  has_teacher_reference_number
                  statutory_induction_complete_details
                  qts_age_range_and_subject
                  qualified_teacher_status_details].freeze

      def self.fields
        FIELDS + [:is_statutory_induction_complete]
      end

      attribute :is_statutory_induction_complete, :boolean

      def updated_teacher_reference_number
        return if has_teacher_reference_number == "no"

        teacher_reference_number
      end

      attr_accessor(*FIELDS)
    end
  end
end
