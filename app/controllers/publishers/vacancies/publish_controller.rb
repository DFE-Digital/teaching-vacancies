class Publishers::Vacancies::PublishController < Publishers::Vacancies::WizardBaseController
  # rubocop:disable Metrics/AbcSize
  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid? && PublishVacancy.new(vacancy, current_publisher, current_organisation).call
      update_google_index(vacancy) if PublishedVacancy.find(vacancy.id).live?

      unless vacancy.contact_email_belongs_to_a_publisher?
        Publishers::AccountInvitationMailer.invite_user(
          contact_email: vacancy.contact_email,
          publisher_email: current_publisher.email,
        ).deliver_now
      end

      redirect_to organisation_job_summary_path(vacancy.id)
    else
      redirect_to organisation_job_path(vacancy.id)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
