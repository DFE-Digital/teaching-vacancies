class Publishers::JobListing::JobRoleForm < Publishers::JobListing::VacancyForm
  attr_accessor :main_job_role

  validates :main_job_role, inclusion: { in: Vacancy.main_job_role_options }

  def self.fields
    %i[main_job_role]
  end

  def params_to_save
    {
      completed_steps: completed_steps,
      main_job_role: main_job_role,
    }.compact
  end
end
