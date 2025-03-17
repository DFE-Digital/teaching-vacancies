class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :working_patterns, presence: true, inclusion: { in: Vacancy::WORKING_PATTERNS }
  validates :is_job_share, inclusion: { in: [true, false] }
  validate :working_patterns_details_does_not_exceed_maximum_words

  FIELDS = %i[working_patterns working_patterns_details].freeze

  def self.fields
    FIELDS + %i[is_job_share]
  end
  attr_accessor(*FIELDS)

  attribute :is_job_share, :boolean

  def params_to_save
    { working_patterns:, working_patterns_details:, is_job_share: }
  end

  private

  def working_patterns_details_does_not_exceed_maximum_words
    return unless number_of_words_exceeds_permitted_length?(75, working_patterns_details)

    errors.add(:working_patterns_details,
               :working_patterns_details_maximum_words,
               message: I18n.t("working_patterns_errors.working_patterns_details.maximum_words"))
  end
end
