class Publishers::Vacancies::PublishController < Publishers::Vacancies::ApplicationController
  before_action :set_vacancy

  def create
    if @vacancy.published?
      redirect_to organisation_job_path(@vacancy.id), notice: t("messages.jobs.already_published")
    elsif all_steps_valid? && PublishVacancy.new(@vacancy, current_publisher, current_organisation).call
      audit_publish_vacancy
      reset_session_vacancy!
      redirect_to organisation_job_summary_path(@vacancy.id)
    else
      redirect_to review_path_with_errors(@vacancy), danger: {
        title: t("errors.jobs.unable_to_publish_title"), body: t("errors.jobs.unable_to_publish_body")
      }
    end
  end

private

  def audit_publish_vacancy
    Auditor::Audit.new(@vacancy, "vacancy.publish", current_publisher_oid).log
    AuditPublishedVacancyJob.perform_later(@vacancy.id)
    update_google_index(@vacancy) if @vacancy.listed?
  end
end
