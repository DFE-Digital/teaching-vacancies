require 'auditor'

class HiringStaff::Vacancies::ApplicationController < HiringStaff::BaseController
  private

  def school
    @school ||= School.find_by! urn: session[:urn]
  end

  def school_id
    params.permit![:school_id]
  end

  def vacancy_id
    params.permit![:job_id]
  end

  def session_vacancy_id
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def store_vacancy_attributes(vacancy_attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(vacancy_attributes)
  end

  def update_vacancy(attributes, vacancy = nil)
    vacancy ||= school.vacancies.find(session_vacancy_id)
    vacancy.assign_attributes(attributes)
    vacancy.refresh_slug
    Auditor::Audit.new(vacancy, 'vacancy.update', current_session_id).log do
      vacancy.save(validate: false)
    end
    vacancy
  end

  def redirect_to_next_step(vacancy)
    next_path = session[:current_step].eql?(:review) ? review_path(vacancy) : next_step
    redirect_to next_path
  end

  def reset_session_vacancy!
    session[:vacancy_attributes] = nil
    session[:current_step] = nil
  end

  def review_path(vacancy)
    school_job_review_path(school_id: school.id, job_id: vacancy.id)
  end

  def redirect_unless_vacancy_session_id
    redirect_to job_specification_school_job_path(school_id: school.id) unless session_vacancy_id
  end

  def retrieve_job_from_db
    school.vacancies.published.find(vacancy_id).attributes
  end

  def source_update?
    params[:source]&.eql?('update')
  end
end
