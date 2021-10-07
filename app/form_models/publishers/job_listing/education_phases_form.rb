class Publishers::JobListing::EducationPhasesForm < Publishers::JobListing::VacancyForm
  validates :phase, presence: true, inclusion: { in: Vacancy.phases.keys }

  def self.fields
    %i[phase]
  end
  attr_accessor(*fields)
end
