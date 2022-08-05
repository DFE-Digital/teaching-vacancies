class Publishers::JobListing::JobSummaryForm < Publishers::JobListing::VacancyForm
  validates :job_advert, presence: true
  validate :about_school_must_not_be_blank

  def self.fields
    %i[job_advert about_school]
  end
  attr_accessor(*fields)

  def about_school_must_not_be_blank
    return if about_school.present?

    organisation = if vacancy&.central_office?
                     "trust"
                   elsif vacancy&.organisations&.many?
                     "schools"
                   else
                     "school"
                   end

    errors.add(:about_school, I18n.t("job_summary_errors.about_school.blank", organisation: organisation))
  end
end
