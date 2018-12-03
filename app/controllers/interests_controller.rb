class InterestsController < ApplicationController
  def new
    vacancy = Vacancy.find(vacancy_id)
    Auditor::Audit.new(vacancy, 'vacancy.get_more_information', nil).log
    AuditExpressInterestEventJob.perform_later([Time.zone.now.iso8601.to_s,
                                                vacancy.id,
                                                vacancy.school.urn,
                                                vacancy.application_link])
    redirect_to(vacancy.application_link)
  end

  private

  def vacancy_id
    return params.require(:vacancy_id) if params.key?('vacancy_id')
    params.require(:job_id)
  end
end
