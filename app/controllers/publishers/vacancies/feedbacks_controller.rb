class Publishers::Vacancies::FeedbacksController < Publishers::Vacancies::ApplicationController
  include FeedbackEventConcerns

  def create
    @vacancy = VacancyPresenter.new(Vacancy.published.find(params[:job_id]))
    @feedback_form = Publishers::JobListing::FeedbackForm.new(feedback_form_params)

    if @feedback_form.valid?
      @feedback = Feedback.create(feedback_attributes)
      trigger_feedback_provided_event
      redirect_to jobs_with_type_organisation_path(:published), success: t("messages.jobs.feedback.success")
    else
      render "publishers/vacancies/summary"
    end
  end

  private

  def feedback_form_params
    params.require(:publishers_job_listing_feedback_form).permit(:comment, :rating)
  end

  def feedback_attributes
    feedback_form_params.merge(feedback_type: "vacancy_publisher", vacancy_id: @vacancy.id)
  end
end
