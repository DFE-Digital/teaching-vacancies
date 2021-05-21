class Publishers::JobListing::CopyVacancyForm < Publishers::JobListing::ImportantDatesForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :job_title

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 100 }, if: proc { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  def job_title_has_no_tags?
    return if job_title == sanitize(job_title, tags: [])

    errors.add(:job_title, I18n.t("job_details_errors.job_title.invalid_characters"))
  end
end
