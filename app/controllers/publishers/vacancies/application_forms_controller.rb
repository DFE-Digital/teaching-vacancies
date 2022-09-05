require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::BaseController
  helper_method :form

  def create
    if applying_for_the_job_details_form_params[:application_form]
      create_application_form
    else
      update_vacancy
    end
  end

  def destroy
    raise "Missing application form" unless vacancy.application_form.id == params[:id]

    send_event(:supporting_document_deleted, vacancy.application_form)
    filename = vacancy.application_form.filename
    vacancy.application_form.purge_later

    redirect_to organisation_job_build_path(vacancy.id, :applying_for_the_job_details, back_to: back_to), flash: {
      success: t("jobs.file_delete_success_message", filename: filename),
    }
  end

  private

  def current_step
    :applying_for_the_job_details
  end

  def form
    @form ||= Publishers::JobListing::ApplyingForTheJobDetailsForm.new(applying_for_the_job_details_form_params, vacancy)
  end

  def applying_for_the_job_details_form_params
    params.require(:publishers_job_listing_applying_for_the_job_details_form)
          .permit(:application_form, :application_link, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def create_application_form
    application_form = form.valid_application_form
    if application_form
      vacancy.application_form.attach(application_form)
      send_event(:supporting_document_created, vacancy.application_form)
    end

    render "publishers/vacancies/build/applying_for_the_job_details"
  end

  def update_vacancy
    if form.valid?
      vacancy.update(form.params_to_save)
      update_google_index(vacancy) if vacancy.listed?
      redirect_to_next_step
    else
      render "publishers/vacancies/build/applying_for_the_job_details"
    end
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
end
