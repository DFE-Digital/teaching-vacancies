class Jobseekers::Profile::QualifiedTeacherStatusForm < BaseForm
  validates :qualified_teacher_status, inclusion: { in: %w[yes no on_track non_teacher] }
  validates :qualified_teacher_status_year, numericality: { less_than_or_equal_to: proc { Time.current.year } }, if: -> { qualified_teacher_status == "yes" }
  validates :teacher_reference_number, presence: true, if: -> { qualified_teacher_status == "yes" }
  validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: false, if: -> { qualified_teacher_status == "yes" || has_teacher_reference_number == "yes" }
  validates_format_of :teacher_reference_number, with: /\A\d{7}\z/, allow_blank: true, if: -> { qualified_teacher_status == "no" || qualified_teacher_status == "on_track" }
  validates :statutory_induction_complete, inclusion: { in: %w[yes no on_track] }, if: -> { qualified_teacher_status == "yes" }
  validates :has_teacher_reference_number, inclusion: { in: %w[yes] }, if: -> { qualified_teacher_status == "yes" }
  validates :has_teacher_reference_number, inclusion: { in: %w[yes no] }, if: -> { qualified_teacher_status == "no" || qualified_teacher_status == "on_track" }

  def self.fields
    %i[qualified_teacher_status qualified_teacher_status_year teacher_reference_number statutory_induction_complete has_teacher_reference_number]
  end

  def statutory_induction_complete_options
    [
      ["yes", I18n.t("helpers.label.jobseekers_profile_qualified_teacher_status_form.statutory_induction_complete_options.yes")],
      ["no", I18n.t("helpers.label.jobseekers_profile_qualified_teacher_status_form.statutory_induction_complete_options.no")],
      ["on_track", I18n.t("helpers.label.jobseekers_profile_qualified_teacher_status_form.statutory_induction_complete_options.on_track")],
    ]
  end

  def updated_teacher_reference_number
    return if has_teacher_reference_number == "no"

    teacher_reference_number
  end

  attr_accessor(*fields)
end
