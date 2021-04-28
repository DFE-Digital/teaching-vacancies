class Jobseekers::JobApplication::Details::Qualifications::Secondary::CommonForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :institution, :year, presence: true
  validate :subjects_and_grades_have_counterparts?, if: -> { row_count > 1 }
  validates :subject1, :grade1, presence: true, if: -> { row_count == 1 || @subjects_and_grades_have_counterparts }
  validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }

  def subjects_and_grades_have_counterparts?
    @subjects_and_grades_have_counterparts = true
    row_attribute_types = %w[subject grade]
    subject_and_grade_attributes.group_by { |key| param_key_digit(key) }.each do |(digit, _param_keys)|
      next unless row_attribute_types.select { |attr| send((attr + digit).to_sym).present? }.one?

      message = I18n.t("qualification_errors.subjects_and_grades_have_counterparts.false")
      # Add error styling to whole fieldset without repeating message
      subject_and_grade_attributes.each { |key| errors.add(key.to_sym, (key == "subject1" ? message : "")) }
      @subjects_and_grades_have_counterparts = false
      break
    end
  end
end
