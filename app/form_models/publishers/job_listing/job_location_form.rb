class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :organisation_ids, :phases

  validates :organisation_ids, presence: true

  class << self
    def fields
      %i[organisation_ids phases]
    end

    def permitted_params
      [{ organisation_ids: [] }]
    end

    def extra_params(_vacancy, form_params)
      organisation_ids = (form_params || {})[:organisation_ids]
      organisations = Organisation.where(id: organisation_ids)

      { phases: organisations.schools.filter_map { |o| o.phase if o.phase.in? Vacancy::SCHOOL_PHASES_MATCHING_VACANCY_PHASES }.uniq }
    end
  end

  def next_step
    :job_title
  end
end
