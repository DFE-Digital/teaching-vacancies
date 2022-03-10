class Publishers::Vacancies::FeedbacksController < Publishers::Vacancies::BaseController
  def create
    @vacancy = VacancyPresenter.new(Vacancy.published.find(params[:job_id]))
    @feedback_form = Publishers::JobListing::FeedbackForm.new(feedback_form_params)

    if @feedback_form.valid?
      @feedback = Feedback.create(feedback_attributes)
      redirect_to jobs_with_type_organisation_path(:published), success: t("messages.jobs.feedback.success")
    else
      render "publishers/vacancies/summary"
    end
  end

  private

  def feedback_form_params
    params.require(:publishers_job_listing_feedback_form)
          .permit(:comment, :email, :rating, :report_a_problem, :user_participation_response)
          .each_value { |value| value.try(:strip!) unless value.frozen? }
  end

  def feedback_attributes
    feedback_form_params.except("report_a_problem").merge(feedback_type: "vacancy_publisher", publisher_id: current_publisher&.id, vacancy_id: @vacancy.id)
  end
end
