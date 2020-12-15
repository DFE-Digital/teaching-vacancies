class Publishers::Vacancies::VacancyPublishFeedbackController < Publishers::Vacancies::ApplicationController
  before_action :set_vacancy, only: %i[new create]

  def new
    return redirect_to organisation_path, notice: t(".already_submitted") if @vacancy.publish_feedback.present?

    @feedback = VacancyPublishFeedback.new
  end

  def create
    @feedback = VacancyPublishFeedback.create(
      vacancy_publish_feedback_params.merge(vacancy: @vacancy, publisher: current_publisher),
    )

    return render "new" unless @feedback.save

    Auditor::Audit.new(@vacancy, "vacancy.publish_feedback.create", current_publisher_oid).log

    redirect_to organisation_path, success: t("messages.jobs.feedback.submitted_html", job_title: @vacancy.job_title)
  end

private

  def vacancy_publish_feedback_params
    params.require(:vacancy_publish_feedback).permit(:comment, :user_participation_response, :email)
  end

  def set_vacancy
    @vacancy = Vacancy.published.find(params[:job_id])
  end
end
