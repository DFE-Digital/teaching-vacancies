# frozen_string_literal: true

module VacancyChecks
  def allow_key_stages?
    allowed_phases = %w[primary secondary through]
    allowed_roles = %w[teacher
                       headteacher
                       deputy_headteacher
                       assistant_headteacher
                       head_of_year_or_phase
                       head_of_department_or_curriculum
                       teaching_assistant]

    phases.intersect?(allowed_phases) && job_roles.intersect?(allowed_roles)
  end

  def allow_subjects?
    phases.any? { |phase| phase.in? %w[secondary sixth_form_or_college through] }
  end

  def salary_types
    [
      salary.present? ? "full_time" : nil,
      actual_salary.present? ? "part_time" : nil,
      pay_scale.present? ? "pay_scale" : nil,
      hourly_rate.present? ? "hourly_rate" : nil,
    ]
  end

  def allow_job_applications?
    enable_job_applications? || uploaded_form?
  end
end
