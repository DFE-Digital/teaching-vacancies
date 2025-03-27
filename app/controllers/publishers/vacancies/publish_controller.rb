class Publishers::Vacancies::PublishController < Publishers::Vacancies::BaseController
  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid?
      published = PublishVacancy.call(vacancy, current_publisher, current_organisation)
      if published.persisted?
        update_google_index(vacancy) if published.listed?
        redirect_to organisation_job_summary_path(published.id)
      else
        redirect_to organisation_job_path(vacancy.id)
      end
    else
      redirect_to organisation_job_path(vacancy.id)
    end
  end
end
