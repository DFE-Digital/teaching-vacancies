class Publishers::JobListing::JobTitleForm < Publishers::JobListing::VacancyForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :job_title, :status

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 75 }, if: -> { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  class << self
    def fields
      %i[job_title]
    end

    def extra_params(vacancy, _form_params)
      { status: vacancy.status || "draft" }
    end
  end

  def job_title_has_no_tags?
    job_title_without_escaped_characters = job_title.delete("&")
    return false if job_title_without_escaped_characters == sanitize(job_title_without_escaped_characters, tags: [])

    errors.add(:job_title, I18n.t("job_title_errors.job_title.invalid_characters"))
  end
end
