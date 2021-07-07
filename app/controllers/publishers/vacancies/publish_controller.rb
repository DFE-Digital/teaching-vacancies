class Publishers::Vacancies::PublishController < Publishers::Vacancies::BaseController
  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid? && PublishVacancy.new(vacancy, current_publisher, current_organisation).call
      update_google_index(vacancy) if vacancy.listed?
      reset_session_vacancy!
      redirect_to organisation_job_summary_path(vacancy.id)
    else
      redirect_to organisation_job_review_path(job_id: vacancy.id, anchor: "errors", source: "publish"),
                  warning: t("errors.jobs.unable_to_publish")
    end
  end
end
