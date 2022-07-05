class Publishers::JobListing::WorkingPatternsForm < Publishers::JobListing::VacancyForm
  validates :working_patterns, presence: true, inclusion: { in: Vacancy.working_patterns.keys }
  validates :working_patterns_details, presence: true, if: -> { working_patterns.include? "part_time" }

  def self.fields
    %i[working_patterns working_patterns_details]
  end
  attr_accessor(*fields)

  def params_to_save
    params[:working_patterns_details] = nil unless params[:working_patterns].include? "part_time"
    params
  end
end
