class Publishers::JobListing::JobRolesMoreForm < Publishers::JobListing::VacancyForm
  attr_accessor :existing_job_roles, :job_roles, :has_send_responsibilities

  validates :job_roles, presence: true
  validates :job_roles, inclusion: { in: Vacancy.job_roles.keys }
  validates :has_send_responsibilities, presence: true, if: proc { job_role_from_previous_step.in?(%w[leadership education_support]) }
  validates :has_send_responsibilities,
            inclusion: { in: %w[yes no] },
            if: proc { job_role_from_previous_step.in?(%w[leadership education_support]) }

  def params_to_save
    {
      completed_steps: completed_steps,
      job_roles: job_roles,
    }.compact
  end

  def job_role_from_previous_step
    @job_role_from_previous_step ||= (existing_job_roles & job_role_options_from_previous_step).first
  end

  private

  def job_role_options_from_previous_step
    I18n.t("helpers.label.publishers_job_listing_job_roles_form.job_roles_options").keys.map(&:to_s)
  end
end
