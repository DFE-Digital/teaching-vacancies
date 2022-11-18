require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::BaseController
  helper_method :form

  def create
    if form.valid?
      # See commit message for 1aa28cce3239c42b1af23d61ae08add3e8c51e5e for context
      vacancy.application_form.attach(form.application_form)
      if application_form_staged_for_replacement?
        send_event(:supporting_document_replaced, vacancy.application_form)
      else
        send_event(:supporting_document_created, vacancy.application_form)
      end

      vacancy.update(form.params_to_save)
      update_google_index(vacancy) if vacancy.listed?

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
    params.require(:publishers_job_listing_application_form_form)
          .permit(:application_form, :application_email, :other_application_email, :application_form_staged_for_replacement)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def send_event(event_type, application_form)
    fail_safe do
      request_event.trigger(
        event_type,
        vacancy_id: StringAnonymiser.new(vacancy.id),
        document_type: "application_form",
        name: application_form.filename,
        size: application_form.byte_size,
        content_type: application_form.content_type,
      )
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
end
