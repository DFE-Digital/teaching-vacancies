class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  validates :main_job_role, inclusion: { in: Vacancy.main_job_role_options }

  def self.fields
    %i[main_job_role]
  end
  attr_accessor(*fields)

  def params_to_save
    {
      completed_steps:,
      main_job_role:,
    }.compact
  end
end
