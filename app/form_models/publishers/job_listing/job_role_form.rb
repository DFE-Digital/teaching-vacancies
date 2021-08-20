class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  attr_accessor :primary_job_role

  validates :primary_job_role, inclusion: { in: Vacancy.primary_job_role_options }

  def params_to_save
    {
      completed_steps: completed_steps,
      primary_job_role: primary_job_role,
    }.compact
  end
end
