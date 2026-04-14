class Publishers::Vacancies::PublishController < Publishers::Vacancies::WizardBaseController
  # rubocop:disable Metrics/AbcSize
  before_action :set_vacancy

  def create
    if vacancy.published?
      redirect_to organisation_job_path(vacancy.id), notice: t("messages.jobs.already_published")
    elsif (not_safe_blobs = uploaded_files_not_safe).any?
      messages = not_safe_blobs.map do |blob|
        if blob.malware_scan_pending?
          t("jobs.file_pending_scan_message", filename: blob.filename)
        else
          t("jobs.file_unsafe_error_message", filename: blob.filename)
        end
      end
      redirect_to organisation_job_review_path(vacancy.id), error: messages.join(". ")
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
  # rubocop:enable Metrics/AbcSize

  private

  def uploaded_files_not_safe
    blobs = []
    blobs << vacancy.application_form.blob if vacancy.application_form.attached?
    blobs += vacancy.supporting_documents.map(&:blob) if vacancy.supporting_documents.attached?
    blobs.reject(&:malware_scan_clean?)
  end
end
