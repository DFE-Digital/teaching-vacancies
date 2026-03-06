class Publishers::Vacancies::FeedbacksController < Publishers::Vacancies::WizardBaseController
  def create
    @vacancy = PublishedVacancy.kept.find(params[:job_id]).decorate
    @feedback_form = Publishers::JobListing::FeedbackForm.new(feedback_form_params)

    if @feedback_form.valid?
      @feedback = Feedback.create(feedback_attributes)
      redirect_to organisation_jobs_with_type_path(:live), success: t("messages.jobs.feedback.success_html")
    else
      render "publishers/vacancies/summary"
    end
  end

  private

  def feedback_form_params
    params.expect(publishers_job_listing_feedback_form: %i[comment email rating report_a_problem user_participation_response occupation])
  end

  # :nocov:
  def feedback_attributes
    feedback_form_params.except("report_a_problem").merge(feedback_type: "vacancy_publisher", publisher_id: current_publisher&.id, vacancy_id: @vacancy.id)
  end
  # :nocov:
end
