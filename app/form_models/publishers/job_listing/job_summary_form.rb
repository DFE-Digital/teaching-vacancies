class Publishers::JobListing::JobSummaryForm < Publishers::JobListing::VacancyForm
  attr_accessor :job_advert, :about_school

  validates :job_advert, presence: true
  validate :about_school_must_not_be_blank

  def about_school_must_not_be_blank
    return if about_school.present?

    case vacancy.job_location
    when "central_office"
      organisation = "trust"
    when "at_one_school"
      organisation = "school"
    when "at_multiple_schools"
      organisation = "schools"
    end
    errors.add(:about_school, I18n.t("job_summary_errors.about_school.blank", organisation: organisation))
  end
end
