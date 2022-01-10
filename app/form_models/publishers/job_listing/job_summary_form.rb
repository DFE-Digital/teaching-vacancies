class Publishers::JobListing::JobSummaryForm < Publishers::JobListing::VacancyForm
  validates :job_advert, presence: true
  validate :about_school_must_not_be_blank

  def self.fields
    %i[job_advert about_school]
  end
  attr_accessor(*fields)

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
    errors.add(:about_school, I18n.t("job_summary_errors.about_school.blank", organisation:))
  end
end
