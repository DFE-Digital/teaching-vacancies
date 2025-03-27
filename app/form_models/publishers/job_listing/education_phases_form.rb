class Publishers::JobListing::EducationPhasesForm < Publishers::JobListing::VacancyForm
  validates :phases, presence: true, inclusion: { in: Vacancy.phases.keys }

  class << self
    def fields
      %i[phases]
    end

    def permitted_params
      [{ phases: [] }]
    end
  end
  attr_accessor(*fields)

  def next_step
    :key_stages
  end
end
