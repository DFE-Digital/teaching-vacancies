class Publishers::Vacancies::PublishController < Publishers::Vacancies::WizardBaseController
  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid? && PublishVacancy.new(vacancy, current_publisher, current_organisation).call
      update_google_index(vacancy) if PublishedVacancy.find(vacancy.id).live?
      # send the email here?
      # some kind of logic to check if vacancy.contact_email is a publisher already, if not send email
      redirect_to organisation_job_summary_path(vacancy.id)
    else
      redirect_to organisation_job_path(vacancy.id)
    end
  end
end
