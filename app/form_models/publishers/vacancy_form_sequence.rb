class Publishers::VacancyFormSequence < FormSequence
  def initialize(vacancy:, organisation:)
    step_process = Publishers::Vacancies::VacancyStepProcess.new(
      :review,
      vacancy: vacancy,
      organisation: organisation,
    )

    super(
      model: vacancy,
      organisation: organisation,
      step_names: step_process.steps,
      form_prefix: "publishers/job_listing",
    )
  end

  private

  def not_validatable_steps
    %i[subjects review].freeze
  end
end
