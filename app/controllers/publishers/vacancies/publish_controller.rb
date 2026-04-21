class Publishers::Vacancies::PublishController < Publishers::Vacancies::WizardBaseController
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  before_action :set_vacancy

  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif (not_safe_blobs = vacancy.unsafe_blobs).any?
      # Pending files are allowed to progress through the wizard steps but blocked here at publish time.
      # This covers files still awaiting their antivirus scan result as well as malicious/errored ones.
      messages = not_safe_blobs.map do |blob|
        if blob.malware_scan_pending?
          t("jobs.file_pending_scan_message", filename: blob.filename)
        else
          t("jobs.file_unsafe_error_message", filename: blob.filename)
        end
      end
      redirect_to organisation_job_review_path(vacancy.id), alert: messages.join(" ")
    elsif all_steps_valid? && PublishVacancy.new(vacancy, current_publisher, current_organisation).call
      update_google_index(vacancy) if PublishedVacancy.find(vacancy.id).live?

      unless vacancy.contact_email_belongs_to_a_publisher?
        Publishers::AccountInvitationMailer.invite_user(
          contact_email: vacancy.contact_email,
          publisher_email: current_publisher.email,
        ).deliver_later
      end

      redirect_to organisation_job_summary_path(vacancy.id)
    else
      redirect_to organisation_job_path(vacancy.id)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
