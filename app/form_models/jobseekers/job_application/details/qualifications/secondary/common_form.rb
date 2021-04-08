class Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :institution, :year, presence: true
  validate :subject_and_grade_correspond?
  validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }

  def subject_and_grade_correspond?
    errors.add(:base, I18n.t("qualification_errors.subject_and_grade_correspond.false")) unless subject.present? && grade.present?
  end
end
