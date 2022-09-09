class Publishers::JobListing::JobDetailsForm < Publishers::JobListing::VacancyForm
  include ActionView::Helpers::SanitizeHelper

  attr_accessor :job_title, :contract_type, :fixed_term_contract_duration, :parental_leave_cover_contract_duration, :key_stages, :subjects, :status, :validate_key_stages

  validates :job_title, presence: true
  validates :job_title, length: { minimum: 4, maximum: 100 }, if: -> { job_title.present? }
  validate :job_title_has_no_tags?, if: proc { job_title.present? }

  validates :key_stages, presence: true, if: -> { validate_key_stages == "true" }
  validate :key_stages_in_phase, if: -> { validate_key_stages == "true" }

  validates :contract_type, inclusion: { in: Vacancy.contract_types.keys }
  validates :fixed_term_contract_duration, presence: true, if: -> { contract_type == "fixed_term" }
  validates :parental_leave_cover_contract_duration, presence: true, if: -> { contract_type == "parental_leave_cover" }

  def self.fields
    %i[job_title contract_type fixed_term_contract_duration parental_leave_cover_contract_duration key_stages subjects]
  end

  def params_to_save
    params.except(:validate_key_stages)
  end

  def job_title_has_no_tags?
    job_title_without_escaped_characters = job_title.delete("&")
    return if job_title_without_escaped_characters == sanitize(job_title_without_escaped_characters, tags: [])

    errors.add(:job_title, I18n.t("job_details_errors.job_title.invalid_characters"))
  end

  def key_stages_in_phase
    return if key_stages.all? { |ks| vacancy.key_stages_for_phases.include? ks.to_sym }

    errors.add(:key_stages, :inclusion)
  end
end
