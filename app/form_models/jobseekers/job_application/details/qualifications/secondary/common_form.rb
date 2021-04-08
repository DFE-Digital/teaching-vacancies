class Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :institution, :year, presence: true
  validate :subject_and_grade_correspond?
  validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }

  def subject_and_grade_correspond?
    return if subject.present? && grade.present?

    errors.add(:subject, I18n.t("qualification_errors.subject_and_grade_correspond.false"))
    # Empty string: highlight grade field with red, but rely on the user reading the error on subject.
    # The resulting empty anchor tag in the error summary correctly links to the field.
    errors.add(:grade, "")
  end
end
