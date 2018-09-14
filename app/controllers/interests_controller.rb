class InterestsController < ApplicationController
  def new
    vacancy = Vacancy.find(vacancy_id)
    Auditor::Audit.new(vacancy, 'vacancy.get_more_information', nil).log
    redirect_to(vacancy.application_link)
  end

  private

  def vacancy_id
    return params.require(:vacancy_id) if params.key?('vacancy_id')
    params.require(:job_id)
  end
end
