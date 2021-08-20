class Publishers::JobListing::JobRolesForm < Publishers::JobListing::VacancyForm
  PRIMARY_JOB_ROLE_OPTIONS = %i[teacher leadership sendco education_support]

  attr_accessor :job_roles

  validates :primary_job_role, inclusion: { in: :job_roles_options }

  def primary_job_role
    job_roles&.first
  end

  def primary_job_role=(role)
    @primary_job_role = role
    @job_roles = [role]
  end

  def job_roles_options
    PRIMARY_JOB_ROLE_OPTIONS.map(&:to_s)
  end

  def params_to_save
    {
      completed_steps: completed_steps,
      job_roles: [primary_job_role],
    }.compact
  end
end
