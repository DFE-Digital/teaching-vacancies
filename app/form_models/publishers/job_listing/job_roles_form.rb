class Publishers::JobListing::JobRolesForm < Publishers::JobListing::VacancyForm
  attr_accessor :job_roles

  validates :job_roles, presence: true
  validates :job_roles, inclusion: { in: Vacancy.job_roles.keys }

  def params_to_save
    {
      completed_steps: completed_steps,
      # Require users to complete entire steps before saving this param, not just the first part of a step,
      # because completing the first part of a step requires different responses in the second part:
      job_roles: job_roles == "sendco" ? job_roles : nil,
    }.compact
  end
end
