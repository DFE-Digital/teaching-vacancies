require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::WizardBaseController
  helper_method :form

  def create
    if form.valid?
      vacancy.application_form.attach(form.application_form) if application_form_uploaded?
      update_vacancy
      send_dfe_analytics_event if application_form_uploaded?
      redirect_to_next_step
    else
      # See commit message for 1aa28cce3239c42b1af23d61ae08add3e8c51e5e for context
      render "publishers/vacancies/build/application_form", locals: { application_form_staged_for_replacement: application_form_staged_for_replacement? }
    end
  end

  private

  def current_step
    :application_form
  end

  def form
    @form ||= Publishers::JobListing::ApplicationFormForm.new(application_form_params, vacancy, current_publisher)
  end

  def application_form_params
    params.expect(publishers_job_listing_application_form_form: %i[application_form application_form_staged_for_replacement])
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def update_vacancy
    vacancy.update(form.params_to_save)
    update_google_index(vacancy) if vacancy.live?
  end

  def event_type
    return :supporting_document_replaced if application_form_staged_for_replacement?

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
    if params[:publishers_job_listing_application_form_form][:back_to_review]
      :review
    elsif params[:publishers_job_listing_application_form_form][:back_to_show]
      :show
    end
  end

  def application_form_staged_for_replacement?
    params[:publishers_job_listing_application_form_form][:application_form_staged_for_replacement].present?
  end

  def application_form_uploaded?
    params[:publishers_job_listing_application_form_form][:application_form].present?
  end
end
