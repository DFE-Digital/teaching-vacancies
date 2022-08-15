class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  # TODO: Working Patterns: Remove call to #reject once all vacancies with legacy working patterns have expired
  validates :working_patterns, presence: true, inclusion: { in: Vacancy.working_patterns.keys.reject { |working_pattern| working_pattern.in?(%w[flexible job_share term_time]) } }
  validates :full_time_details, presence: true, if: -> { working_patterns&.include?("full_time") }
  validates :part_time_details, presence: true, if: -> { working_patterns&.include?("part_time") }
  validate :full_time_details_does_not_exceed_maximum_words, if: -> { working_patterns&.include?("full_time") }
  validate :part_time_details_does_not_exceed_maximum_words, if: -> { working_patterns&.include?("part_time") }

  def self.fields
    %i[working_patterns full_time_details part_time_details]
  end
  attr_accessor(*fields)

  def self.optional?
    false
  end

  private

  def full_time_details_does_not_exceed_maximum_words
    errors.add(:full_time_details, :full_time_details_maximum_words, message: I18n.t("working_patterns_errors.full_time_details.maximum_words")) if full_time_details&.split&.length&.>(50)
  end

  def part_time_details_does_not_exceed_maximum_words
    errors.add(:part_time_details, :part_time_details_maximum_words, message: I18n.t("working_patterns_errors.part_time_details.maximum_words")) if part_time_details&.split&.length&.>(50)
  end
end
