class Publishers::JobListing::JobDetailsForm < Publishers::JobListing::VacancyForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :job_title, :job_roles, :suitable_for_nqt, :working_patterns, :contract_type, :contract_type_duration, :subjects, :job_location, :readable_job_location, :status

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 100 }, if: proc { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  validates :suitable_for_nqt, inclusion: { in: %w[yes no] }

  validates :working_patterns, presence: true

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :contract_type_duration, presence: true, if: -> { contract_type == "fixed_term" }

  def job_title_has_no_tags?
    job_title_without_escaped_characters = job_title.delete("&")
    return if job_title_without_escaped_characters == sanitize(job_title_without_escaped_characters, tags: [])

    errors.add(:job_title, I18n.t("job_details_errors.job_title.invalid_characters"))
  end
end
