class HiringStaff::Vacancies::ApplicationDetailsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy

  def new
    @application_details_form = ApplicationDetailsForm.new(session[:vacancy_attributes].with_indifferent_access)
    @application_details_form.valid? if %i[step_4 review].include?(session[:current_step])
  end

  def create
    @application_details_form = ApplicationDetailsForm.new(application_details_form_params)
    store_vacancy_attributes(@application_details_form.attributes)

    if @application_details_form.valid?
      session[:completed_step] = current_step
      vacancy = update_vacancy(@application_details_form.params_to_save)
      redirect_to_next_step(vacancy)
    else
      session[:current_step] = :step_4 unless session[:current_step].eql?(:review)
      redirect_to application_details_school_job_path(anchor: 'errors')
    end
  end

  def edit
    vacancy_attributes = source_update? ? session[:vacancy_attributes] : retrieve_job_from_db

    @application_details_form = ApplicationDetailsForm.new(vacancy_attributes.with_indifferent_access)
    @application_details_form.valid?
  end

  def update
    vacancy = current_school.vacancies.published.find(vacancy_id)
    @application_details_form = ApplicationDetailsForm.new(application_details_form_params)
    @application_details_form.status = vacancy.status
    @application_details_form.id = vacancy.id

    if @application_details_form.valid?
      reset_session_vacancy!
      update_vacancy(@application_details_form.params_to_save, vacancy)
      update_google_index(vacancy) if vacancy.listed?
      redirect_to edit_school_job_path(vacancy.id), success: I18n.t('messages.jobs.updated')
    else
      store_vacancy_attributes(@application_details_form.attributes)
      redirect_to edit_school_job_application_details_path(vacancy.id,
                                                           anchor: 'errors',
                                                           source: 'update')
    end
  end

  private

  def application_details_form_params
    params.require(:application_details_form)
          .permit(:application_link, :contact_email, :expiry_time,
                  :expires_on_dd, :expires_on_mm, :expires_on_yyyy,
                  :publish_on_dd, :publish_on_mm, :publish_on_yyyy,
                  :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem).merge(completed_step: current_step)
  end

  def next_step
    school_job_job_summary_path(@vacancy.id)
  end
end
