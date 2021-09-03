class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  attr_accessor :working_patterns, :working_patterns_details

  validates :working_patterns, presence: true
end
