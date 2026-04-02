require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::WizardBaseController
  helper_method :form

  def create
    if !application_form_uploaded? && vacancy.application_form.attached?
      update_vacancy
      return redirect_to_next_step
    end

    if form.valid?
      vacancy.application_form.attach(form.application_form)
      update_vacancy
      send_dfe_analytics_event
      redirect_to_next_step
    else
      render "publishers/vacancies/build/application_form"
    end
  end

  def destroy
    vacancy.application_form.purge
    redirect_to organisation_job_build_path(vacancy.id, :application_form)
  end

  private

  def current_step
    :application_form
  end

  def form
    @form ||= Publishers::JobListing::ApplicationFormForm.new(application_form_params, vacancy)
  end

  def application_form_params
    params.expect(publishers_job_listing_application_form_form: %i[application_form]).merge(completed_steps: completed_steps)
  end

  def update_vacancy
    vacancy.update(form.params_to_save)
    update_google_index(vacancy) if vacancy.live?
  end

  def event_type
    :supporting_document_created
  end

  def send_dfe_analytics_event
    fail_safe do
      event_data = {
        vacancy_id: vacancy.id,
        document_type: "application_form",
        name: vacancy.application_form.filename,
        size: vacancy.application_form.byte_size,
        content_type: vacancy.application_form.content_type,
      }

      event = DfE::Analytics::Event.new
        .with_type(event_type)
        .with_request_details(request)
        .with_response_details(response)
        .with_user(current_publisher)
        .with_data(data: event_data)

      DfE::Analytics::SendEvents.do([event])
    end
  end

  def back_link_destination
    form_params = params[:publishers_job_listing_application_form_form] || {}
    if form_params[:back_to_review]
      :review
    elsif form_params[:back_to_show]
      :show
    end
  end

  def application_form_uploaded?
    params.dig(:publishers_job_listing_application_form_form, :application_form).present?
  end
end
