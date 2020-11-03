class HiringStaff::Vacancies::PublishController < HiringStaff::Vacancies::ApplicationController
  def create
    if @vacancy.published?
      redirect_to organisation_job_path(@vacancy.id), notice: I18n.t("messages.jobs.already_published")
    elsif PublishVacancy.new(@vacancy, current_user, current_organisation).call
      audit_publish_vacancy
      reset_session_vacancy!
      redirect_to organisation_job_summary_path(@vacancy.id)
    else
      redirect_to review_path_with_errors(@vacancy), danger: {
        title: I18n.t("errors.jobs.unable_to_publish_title"), body: I18n.t("errors.jobs.unable_to_publish_body")
      }
    end
  end

private

  def audit_publish_vacancy
    Auditor::Audit.new(@vacancy, "vacancy.publish", current_session_id).log
    AuditPublishedVacancyJob.perform_later(@vacancy.id)
    update_google_index(@vacancy) if @vacancy.listed?
  end
end
