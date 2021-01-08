module VacancyJobSummaryValidations
  extend ActiveSupport::Concern

  included do
    validates :job_summary, presence: true
    validate :about_school_must_not_be_blank
  end

  def about_school_must_not_be_blank
    return if about_school.present?

    # Since vacancy is set by VacancyForm.initialize, it can be undefined here.
    case job_location
    when "central_office"
      organisation = "trust"
    when "at_one_school"
      organisation = "school"
    when "at_multiple_schools"
      organisation = "schools"
    end
    errors.add(:about_school,
               I18n.t("job_summary_errors.about_school.blank",
                      organisation: organisation))
  end
end
