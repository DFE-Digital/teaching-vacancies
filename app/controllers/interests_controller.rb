class InterestsController < ApplicationController
  def new
    audit_click unless publisher_signed_in?
    redirect_to(vacancy.application_link)
  end

  private

  def audit_click
    PersistVacancyGetMoreInfoClickJob.perform_later(vacancy.id)
    Auditor::Audit.new(vacancy, "vacancy.get_more_information", current_publisher_oid).log
    AuditExpressInterestEventJob.perform_later(
      datestamp: Time.current.iso8601.to_s,
      vacancy_id: vacancy.id,
      school_urn: vacancy.parent_organisation.urn,
      application_link: vacancy.application_link,
    )
  end

  def vacancy
    @vacancy ||= Vacancy.find(vacancy_id)
  end

  def vacancy_id
    return params.require(:vacancy_id) if params.key?("vacancy_id")

    params.require(:job_id)
  end
end
