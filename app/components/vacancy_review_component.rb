class VacancyReviewComponent < ReviewComponent
  renders_many(:sections, lambda do |section_name, **kwargs|
    VacancyReviewComponent::Section.new(
      @vacancy,
      name: section_name,
      back_to: @back_to,
      show_errors: @show_errors,
      **kwargs,
    )
  end)

  def initialize(vacancy, step_process:, back_to:, show_errors: false, classes: [], html_attributes: {})
    super(
      classes: Array(classes) + ["vacancy"],
      html_attributes: html_attributes,
      namespace: "publishers/vacancies",
      show_tracks: !vacancy.published?,
    )

    @back_to = back_to
    @show_errors = show_errors
    @step_process = step_process
    @vacancy = vacancy
  end

  def error_presenter
    @error_presenter ||= ErrorSummaryPresenter.new(
      @vacancy.errors,
      lambda do |e|
        organisation_job_build_path(
          job_id: @vacancy.id,
          id: e.options[:step],
          back_to: @back_to,
        )
      end,
    )
  end

  private

  def track_assigns
    super.merge(
      step_process: @step_process,
      vacancy: @vacancy,
    )
  end
end
