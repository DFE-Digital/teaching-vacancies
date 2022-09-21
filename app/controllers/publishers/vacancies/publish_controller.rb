class Publishers::Vacancies::PublishController < Publishers::Vacancies::BaseController
  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid? && PublishVacancy.new(vacancy, current_publisher, current_organisation).call
      update_google_index(vacancy) if vacancy.listed?
      redirect_to organisation_job_summary_path(vacancy.id)
    else
      redirect_to organisation_job_path(vacancy.id)
    end
  end
end
