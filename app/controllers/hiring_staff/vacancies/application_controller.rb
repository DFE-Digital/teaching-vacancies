require 'auditor'
require 'indexing'

class HiringStaff::Vacancies::ApplicationController < HiringStaff::BaseController
  before_action :set_vacancy

  def school_id
    params.permit![:school_id]
  end

  def vacancy_id
    params.permit![:job_id]
  end

  def session_vacancy_id
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def set_vacancy
    if params[:job_id]
      @vacancy = current_school.vacancies.find(params[:job_id])
    elsif session_vacancy_id
      @vacancy = current_school.vacancies.find(session_vacancy_id)
    end
  end

  def current_step
    params[:create_step]
  end

  def store_vacancy_attributes(attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(attributes.compact)
  end

  def update_vacancy(attributes, vacancy = nil)
    vacancy ||= current_school.vacancies.find(session_vacancy_id)

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
    school_job_review_path(school_id: current_school.id, job_id: vacancy.id)
  end

  def review_path_with_errors(vacancy)
    school_job_review_path(job_id: vacancy.id, anchor: 'errors', source: 'publish')
  end

  def redirect_unless_vacancy
    redirect_unless_vacancy_session_id unless @vacancy
  end

  def redirect_unless_vacancy_session_id
    redirect_to job_specification_school_job_path(school_id: current_school.id) unless session_vacancy_id
  end

  def retrieve_job_from_db
    current_school.vacancies.published.find(vacancy_id).attributes
  end

  def source_update?
    params[:source]&.eql?('update')
  end

  def update_google_index(job)
    return unless Rails.env.production?

    url = job_url(job, protocol: 'https')
    UpdateGoogleIndexQueueJob.perform_later(url)
  end

  def remove_google_index(job)
    return unless Rails.env.production?

    url = job_url(job, protocol: 'https')
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def strip_empty_checkboxes(form_key, fields)
    fields.each do |field|
      params[form_key][field] = params[form_key][field]&.reject(&:blank?)
    end
  end

  def flatten_date_hash(hash, field)
    %w(1 2 3).map { |i| hash[:"#{field}(#{i}i)"].to_i }
  end

  def convert_multiparameter_attributes_to_dates(form_key, fields)
    date_errors = {}
    fields.each do |field|
      date_params = flatten_date_hash(
        params[form_key].extract!(:"#{field}(1i)", :"#{field}(2i)", :"#{field}(3i)"), field
      )
      begin
        params[form_key][field] = Date.new(*date_params) unless date_params.all?(0)
      rescue ArgumentError
        date_errors[field] = I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.invalid")
      end
    end
    date_errors
  end

  def add_errors_to_form(errors, form_object)
    errors.each do |field, error|
      form_object.errors.add(field, error)
    end
  end
end
