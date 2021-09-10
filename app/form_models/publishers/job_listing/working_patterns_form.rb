class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  attr_accessor :working_patterns, :working_patterns_details

  validates :working_patterns, presence: true, inclusion: { in: Vacancy.working_patterns.keys }

  def self.fields
    %i[working_patterns working_patterns_details]
  end
end
