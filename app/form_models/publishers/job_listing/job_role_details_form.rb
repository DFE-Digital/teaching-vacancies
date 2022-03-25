class Publishers::JobListing::JobRoleDetailsForm < Publishers::JobListing::VacancyForm
  attr_writer :send_responsible

  validates :send_responsible,
            inclusion: { in: %w[yes no] },
            if: -> { vacancy.main_job_role.in?(%w[leadership middle_leader teaching_assistant education_support]) }

  def self.fields
    %i[additional_job_roles]
  end
  attr_accessor(*fields)

  def teacher_additional_job_roles_options
    %w[ect_suitable send_responsible]
  end

  def send_responsible
    # If a value has been set because the form has been submitted, return that
    return @send_responsible if @send_responsible

    # If this step hasn't been completed before, return nil so the form doesn't assume "no"
    # by default
    return nil unless vacancy.completed_steps.include?("job_role_details")

    # Otherwise, determine value based on presence in additional_job_roles
    "send_responsible".in?(additional_job_roles) ? "yes" : "no"
  end

  def additional_job_roles_to_save
    if vacancy.main_job_role == "teacher"
      additional_job_roles
    else
      @send_responsible == "yes" ? ["send_responsible"] : []
    end
  end

  def params_to_save
    {
      completed_steps: completed_steps,
      additional_job_roles: additional_job_roles_to_save,
    }.compact
  end
end
