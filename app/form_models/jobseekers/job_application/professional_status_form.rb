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
        has_teacher_reference_number
      ].freeze

      attr_accessor(*FIELDS)

      class << self
        def storable_fields
          FIELDS
        end

        def unstorable_fields
          %i[has_teacher_reference_number professional_status_section_completed]
        end

        def load_form(model)
          load_form_attributes(model.attributes.merge(completed_attrs(model, :professional_status)))
        end
      end

      def statutory_induction_complete_options
        [
          ["yes", I18n.t("helpers.label.jobseekers_job_application_professional_status_form.statutory_induction_complete_options.yes")],
          ["no", I18n.t("helpers.label.jobseekers_job_application_professional_status_form.statutory_induction_complete_options.no")],
          ["on_track", I18n.t("helpers.label.jobseekers_job_application_professional_status_form.statutory_induction_complete_options.on_track")],
        ]
      end

      def initialize(attributes = {})
        jobseeker_profile = attributes.delete(:jobseeker_profile)
        super

        return unless jobseeker_profile

        self.teacher_reference_number ||= jobseeker_profile.teacher_reference_number
        self.has_teacher_reference_number ||= jobseeker_profile.has_teacher_reference_number
      end

      validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }, if: -> { professional_status_section_completed }
      validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                                                if: -> { qualified_teacher_status == "yes" && professional_status_section_completed }
      validates :statutory_induction_complete, inclusion: { in: %w[yes no on_track] }, if: -> { professional_status_section_completed }

      validates :teacher_reference_number, presence: true, if: -> { qualified_teacher_status == "yes" && professional_status_section_completed }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: false, if: -> { qualified_teacher_status == "yes" || has_teacher_reference_number == "yes" }
      validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true, if: -> { qualified_teacher_status.in?(%w[no on_track]) }
      validates :has_teacher_reference_number, inclusion: { in: %w[yes] }, if: -> { qualified_teacher_status == "yes" && professional_status_section_completed }
      validates :has_teacher_reference_number, inclusion: { in: %w[yes no] }, if: -> { qualified_teacher_status.in?(%w[no on_track]) && professional_status_section_completed }

      attribute :professional_status_section_completed, :boolean

      validates :professional_status_section_completed, inclusion: { in: [true, false], allow_nil: false }
    end
  end
end
