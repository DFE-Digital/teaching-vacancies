require 'auditor'
require 'indexing'

class HiringStaff::Vacancies::ApplicationController < HiringStaff::BaseController
  include HiringStaff::JobCreationHelper

  before_action :set_vacancy

  def vacancy_id
    params.permit![:job_id]
  end

  def session_vacancy_id
    session[:vacancy_attributes].present? ? session[:vacancy_attributes]['id'] : false
  end

  def set_vacancy
    if params[:job_id]
      @vacancy = current_organisation.vacancies.find(params[:job_id])
    elsif params[:id]
      @vacancy = current_organisation.vacancies.find(params[:id])
    elsif session_vacancy_id
      @vacancy = current_organisation.vacancies.find(session_vacancy_id)
    end
  end

  def store_vacancy_attributes(attributes)
    session[:vacancy_attributes] ||= {}
    session[:vacancy_attributes].merge!(attributes.compact)
  end

  def update_vacancy(attributes, vacancy = nil)
    vacancy ||= current_organisation.vacancies.find(session_vacancy_id)
    vacancy.assign_attributes(attributes)
    vacancy.refresh_slug
    Auditor::Audit.new(vacancy, 'vacancy.update', current_session_id).log do
      vacancy.save(validate: false)
    end
    vacancy
  end

  def save_vacancy_as_draft_if_save_and_return_later(attributes, vacancy)
    if params[:commit] == I18n.t('buttons.save_and_return_later')
      vacancy = update_vacancy(attributes, vacancy)
      redirect_to_draft(vacancy.id, vacancy.job_title)
    end
  end

  def redirect_to_draft(vacancy_id, job_title)
    redirect_to jobs_with_type_organisation_path('draft'),
                success: I18n.t('messages.jobs.draft_saved_html', job_title: job_title)
  end

  def redirect_to_next_step_if_continue(vacancy_id, job_title = nil)
    if params[:commit] == I18n.t('buttons.continue')
      redirect_to_next_step(vacancy_id)
    elsif params[:commit] == I18n.t('buttons.update_job')
      updated_job_path = @vacancy.published? ?
        edit_organisation_job_path(vacancy_id) : organisation_job_review_path(vacancy_id)
      redirect_to updated_job_path, success: {
        title: I18n.t('messages.jobs.listing_updated', job_title: job_title),
        body: I18n.t('messages.jobs.manage_jobs_html', link: helpers.back_to_manage_jobs_link(@vacancy))
      }
    end
  end

  def redirect_to_next_step(vacancy_id)
    next_path = session[:current_step].eql?(:review) ? organisation_job_review_path(vacancy_id) : next_step
    redirect_to next_path
  end

  def reset_session_vacancy!
    session[:vacancy_attributes] = nil
    session[:current_step] = nil
  end

  def review_path_with_errors(vacancy)
    organisation_job_review_path(job_id: vacancy.id, anchor: 'errors', source: 'publish')
  end

  def redirect_unless_vacancy
    redirect_unless_vacancy_session_id unless @vacancy
  end

  def redirect_unless_vacancy_session_id
    redirect_to job_specification_organisation_job_path(school_id: current_school.id) unless session_vacancy_id
  end

  def retrieve_job_from_db
    current_organisation.vacancies.published.find(vacancy_id).attributes
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
        if date_params.all?(0)
          params[form_key][field] = nil
        else
          params[form_key][field] = Date.new(*date_params)
        end
      rescue ArgumentError
        date_errors[field] = I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.invalid")
      end
    end
    date_errors
  end

  def add_errors_to_form(errors, form_object)
    errors.each do |field, error|
      form_object.errors.messages[field].unshift(error)
    end
  end

  def set_up_form(form_class)
    @form = form_class.new(form_params)
  end

  def set_up_url
    @form_submission_url_method = @vacancy&.persisted? ? 'patch' : 'post'
    @form_submission_url = form_submission_path(@vacancy&.id)
  end
end
