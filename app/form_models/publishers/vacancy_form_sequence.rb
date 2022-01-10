class Publishers::VacancyFormSequence < FormSequence
  def initialize(vacancy:, organisation:)
    step_process = Publishers::Vacancies::VacancyStepProcess.new(
      :review,
      vacancy:,
      organisation:,
    )

    super(
      model: vacancy,
      organisation:,
      step_names: step_process.steps,
      form_prefix: "publishers/job_listing",
    )
  end

  private

  def not_validatable_steps
    %i[documents review].freeze
  end
end
