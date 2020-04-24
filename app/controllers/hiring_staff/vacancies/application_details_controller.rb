class HiringStaff::Vacancies::ApplicationDetailsController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy
  before_action :set_up_application_details_form, only: %i[update]

  def show
    @application_details_form = ApplicationDetailsForm.new(@vacancy.attributes.symbolize_keys)
  end

  def update
    @application_details_form.id = @vacancy.id
    @application_details_form.status = @vacancy.status

    if @application_details_form.complete_and_valid?
      update_vacancy(@application_details_form.params_to_save, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue(@vacancy.id)
    end

    render :show
  end

  private

  def set_up_application_details_form
    publish_in_past = @vacancy.published? && @vacancy.reload.publish_on.past?
    delete_publish_on_params if publish_in_past
    dates_to_convert = publish_in_past ? [:expires_on] : [:publish_on, :expires_on]
    date_errors = convert_multiparameter_attributes_to_dates(:application_details_form, dates_to_convert)
    @application_details_form = ApplicationDetailsForm.new(application_details_form_params)
    add_errors_to_form(date_errors, @application_details_form)
  end

  def application_details_form_params
    params.require(:application_details_form)
          .permit(:application_link, :contact_email, :expiry_time,
                  :publish_on, :expires_on,
                  :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem).merge(completed_step: current_step)
  end

  def delete_publish_on_params
    params.require(:application_details_form).delete('publish_on(3i)')
    params.require(:application_details_form).delete('publish_on(2i)')
    params.require(:application_details_form).delete('publish_on(1i)')
  end

  def next_step
    school_job_job_summary_path(@vacancy.id)
  end
end
