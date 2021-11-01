class InterestsController < ApplicationController
  def new
    request_event.trigger(:vacancy_get_more_info_clicked, vacancy_id: StringAnonymiser.new(vacancy.id))

    redirect_to vacancy.application_link, status: :moved_permanently
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
