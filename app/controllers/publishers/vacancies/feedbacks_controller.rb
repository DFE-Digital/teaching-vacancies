class Publishers::Vacancies::FeedbacksController < Publishers::Vacancies::BaseController
  def new
    @feedback_form = Publishers::JobListing::FeedbackForm.new
  end

  def create
    @feedback_form = Publishers::JobListing::FeedbackForm.new(feedback_form_params)

    if @feedback_form.valid?
      @feedback = Feedback.create(feedback_attributes)
      redirect_to jobs_with_type_organisation_path(:published), success: t("messages.jobs.feedback.success_html")
    else
      render "publishers/vacancies/feedbacks/new"
    end
  end

  private

  def feedback_form_params
    params.require(:publishers_job_listing_feedback_form).permit(:comment, :email, :rating, :report_a_problem, :user_participation_response)
  end

  def feedback_attributes
    feedback_form_params.except("report_a_problem").merge(feedback_type: "vacancy_publisher", publisher_id: current_publisher&.id, vacancy_id: vacancy.id)
  end
end
