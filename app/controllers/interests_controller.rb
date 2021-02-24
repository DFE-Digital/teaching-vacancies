class InterestsController < ApplicationController
  def new
    PersistVacancyGetMoreInfoClickJob.perform_later(vacancy.id) unless publisher_signed_in?
    request_event.trigger(:vacancy_get_more_info_clicked, vacancy_id: vacancy.id)

    redirect_to(vacancy.application_link)
  end

  private

  def vacancy
    @vacancy ||= Vacancy.find(vacancy_id)
  end

  def vacancy_id
    return params.require(:vacancy_id) if params.key?("vacancy_id")

    params.require(:job_id)
  end
end
