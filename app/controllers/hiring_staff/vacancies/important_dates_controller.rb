class HiringStaff::Vacancies::ImportantDatesController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy
  before_action :set_up_important_dates_form, only: %i[update]
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(@important_dates_form.params_to_save, @vacancy)
  end

  def show
    @important_dates_form = ImportantDatesForm.new(@vacancy.attributes.symbolize_keys)
  end

  def update
    @important_dates_form.id = @vacancy.id
    @important_dates_form.status = @vacancy.status

    if @important_dates_form.complete_and_valid?
      update_vacancy(@important_dates_form.params_to_save, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue(@vacancy.id, @vacancy.job_title)
    end

    render :show
  end

  private

  def set_up_important_dates_form
    publish_in_past = @vacancy.published? && @vacancy.reload.publish_on.past?
    delete_publish_on_params if publish_in_past
    dates_to_convert = publish_in_past ? [:starts_on, :expires_on] : [:starts_on, :publish_on, :expires_on]
    date_errors = convert_multiparameter_attributes_to_dates(:important_dates_form, dates_to_convert)
    @important_dates_form = ImportantDatesForm.new(important_dates_params)
    add_errors_to_form(date_errors, @important_dates_form)
  end

  def important_dates_params
    params.require(:important_dates_form)
          .permit(:state, :starts_on, :publish_on, :expires_on,
                  :expiry_time, :expiry_time_hh, :expiry_time_mm, :expiry_time_meridiem)
          .merge(completed_step: current_step)
  end

  def delete_publish_on_params
    params.require(:important_dates_form).delete('publish_on(3i)')
    params.require(:important_dates_form).delete('publish_on(2i)')
    params.require(:important_dates_form).delete('publish_on(1i)')
  end

  def next_step
    school_job_supporting_documents_path(@vacancy.id)
  end
end
