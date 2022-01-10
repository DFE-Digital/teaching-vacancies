class Publishers::JobListing::CopyVacancyForm < Publishers::JobListing::ImportantDatesForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :job_title

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 100 }, if: proc { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  def params_to_save
    # `completed_steps` is nil by default and would overwrite the copied vacancy's value
    super.except(:completed_steps).merge(job_title:)
  end

  private

  def job_title_has_no_tags?
    job_title_without_escaped_characters = job_title.delete("&")
    return if job_title_without_escaped_characters == sanitize(job_title_without_escaped_characters, tags: [])

    errors.add(:job_title, I18n.t("job_details_errors.job_title.invalid_characters"))
  end
end
