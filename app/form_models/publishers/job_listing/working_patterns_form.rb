class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  validates :working_patterns, presence: true, inclusion: { in: Vacancy.working_patterns.keys }
  validate :working_patterns_details_does_not_exceed_maximum_words

  def self.fields
    %i[working_patterns working_patterns_details]
  end
  attr_accessor(*fields)

  def self.optional?
    false
  end

  def params_to_save
    { working_patterns:, working_patterns_details: }
  end

  private

  def working_patterns_details_does_not_exceed_maximum_words
    return unless working_patterns_details&.split&.length&.>(50)

    errors.add(:working_patterns_details, :working_patterns_details_maximum_words, message: I18n.t("working_patterns_errors.working_patterns_details.maximum_words"))
  end
end
