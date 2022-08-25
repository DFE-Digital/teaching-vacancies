class Publishers::JobListing::EducationPhasesForm < Publishers::JobListing::VacancyForm
  validates :phases, presence: true, inclusion: { in: Vacancy.phases.keys }

  def self.fields
    %i[phases]
  end
  attr_accessor(*fields)
end
