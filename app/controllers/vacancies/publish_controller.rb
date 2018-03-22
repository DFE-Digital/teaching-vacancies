class Vacancies::PublishController < Vacancies::ApplicationController
  def create
    vacancy = Vacancy.find(vacancy_id)
    if PublishVacancy.new(vacancy: vacancy).call
      session[:vacancy_attributes] = nil
      redirect_to school_vacancy_path(school_id: school.id, id: vacancy_id), notice: 'The vacancy is not available'

    else
      redirect_to school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy_id),
                  notice: 'We were unable to publish your vacancy. Please try again.'
    end
  end

  private

  def vacancy_id
    params.permit(:vacancy_id)[:vacancy_id]
  end
end
