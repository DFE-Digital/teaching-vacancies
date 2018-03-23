class HiringStaff::Vacancies::ApplicationController < HiringStaff::BaseController
  private

  def school
    @school ||= School.find_by(id: school_id)
  end

  def school_id
    params.permit![:school_id]
  end

  def session_vacancy_id
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def store_vacancy_attributes(vacancy_attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(vacancy_attributes)
  end

  def update_vacancy(attributes)
    vacancy = school.vacancies.find(session_vacancy_id)
    vacancy.update_attributes(attributes)
    vacancy
  end

  def redirect_to_next_step(vacancy)
    next_path = session[:current_step].eql?('review') ? review_path(vacancy) : next_step
    redirect_to next_path
  end

  def reset_session_vacancy!
    session[:vacancy_attributes] = nil
    session[:current_step] = nil
  end

  def review_path(vacancy)
    school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
  end
end
