class Publishers::Vacancies::VacancyStepProcess < StepProcess
  attr_reader :vacancy, :organisation, :session

  def initialize(current_step, vacancy:, organisation:, session: {})
    @vacancy = vacancy
    @organisation = organisation
    @session = session

    super(current_step, {
      job_role: job_role_steps,
      job_location: job_location_steps,
      job_details: job_details_steps,
      working_patterns: %i[working_patterns],
      pay_package: %i[pay_package],
      important_dates: %i[important_dates],
      documents: %i[documents],
      applying_for_the_job: %i[applying_for_the_job],
      job_summary: %i[job_summary],
      review: %i[review],
    })
  end

  def validatable_steps(top_level: false)
    initial_set = (top_level ? step_groups.keys : steps)

    initial_set - %i[documents review]
  end

  def validate_all_steps
    validatable_steps.each.with_object({}) { |s, h| h[s] = validate_step(s) }
  end

  def all_steps_valid?
    validate_all_steps.values.all?(&:valid?)
  end

  def previous_step_or_review
    return steps.last if session[:current_step] == :review && first_of_group?

    previous_step
  end

  private

  def validate_step(step_name)
    step_form = "publishers/job_listing/#{step_name}_form".camelize.constantize

    # We need to merge in the current organisation otherwise the form will always be invalid for local authority users
    vacancy_params = vacancy
      .slice(*step_form.fields)
      .merge(current_organisation: organisation)

    step_form.new(vacancy_params, vacancy).tap do |form|
      form.valid?
      vacancy.errors.merge!(
        form.errors.tap do |errors|
          errors.each { |e| e.options[:step] = step_name }
        end,
      )
    end
  end

  def job_role_steps
    if vacancy.main_job_role == "sendco"
      %i[job_role]
    else
      %i[job_role job_role_details]
    end
  end

  def job_location_steps
    return nil if organisation.school?

    most_up_to_date_job_location = session[:job_location].presence || vacancy.job_location
    if most_up_to_date_job_location == "central_office"
      %i[job_location]
    else
      %i[job_location schools]
    end
  end

  def job_details_steps
    if vacancy.allow_phase_to_be_set?
      %i[education_phases job_details]
    else
      %i[job_details]
    end
  end
end
