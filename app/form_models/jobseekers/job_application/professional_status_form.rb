class Jobseekers::JobApplication::ProfessionalStatusForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[
      qualified_teacher_status
      qualified_teacher_status_year
      qualified_teacher_status_details
      statutory_induction_complete
      teacher_reference_number
      has_teacher_reference_number
]
  end
  attr_accessor(*fields)

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

    if jobseeker_profile
      self.teacher_reference_number ||= jobseeker_profile.teacher_reference_number
      self.has_teacher_reference_number ||= jobseeker_profile.has_teacher_reference_number
    end
  end

  validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track] }
  validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                                            if: -> { qualified_teacher_status == "yes" }
  validates :statutory_induction_complete, inclusion: { in: %w[yes no on_track] }

  validates :teacher_reference_number, presence: true, if: -> { qualified_teacher_status == "yes" }
  validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: false, if: -> { qualified_teacher_status == "yes" || has_teacher_reference_number == "yes" }
  validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true, if: -> { qualified_teacher_status == "no" || qualified_teacher_status == "on_track" }
  validates :has_teacher_reference_number, inclusion: { in: %w[yes] }, if: -> { qualified_teacher_status == "yes" }
  validates :has_teacher_reference_number, inclusion: { in: %w[yes no] }, if: -> { qualified_teacher_status == "no" || qualified_teacher_status == "on_track" }
end
