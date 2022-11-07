require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::BaseController
  helper_method :form

  def create
    if application_form_params[:application_form]
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

    redirect_to organisation_job_build_path(vacancy.id, :application_form, back_to_review: params[:back_to_review], back_to_show: params[:back_to_show]), flash: {
      success: t("jobs.file_delete_success_message", filename: filename),
    }
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
          .permit(:application_form, :application_email, :other_application_email)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def create_application_form
    application_form = form.valid_application_form
    if application_form
      vacancy.application_form.attach(application_form)
      send_event(:supporting_document_created, vacancy.application_form)
      return redirect_to_next_step
    end

    # So they are taken back to the show or review page upon clicking the back link, even after creating a document
    params["back_to_#{back_link_destination}"] = "true" if back_link_destination

    render "publishers/vacancies/build/application_form"
  end

  def update_vacancy
    if form.valid?
      vacancy.update(form.params_to_save)
      update_google_index(vacancy) if vacancy.listed?
      return redirect_to_next_step
    else
      # So they are taken back to the show or review page upon clicking the back link, even after uploading a school_visit
      params["back_to_#{back_link_destination}"] = "true" if back_link_destination

      render "publishers/vacancies/build/application_form"
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

  def back_link_destination
    if params[:publishers_job_listing_application_form_form][:back_to_review]
      :review
    elsif params[:publishers_job_listing_application_form_form][:back_to_show]
      :show
    end
  end
end
