require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::BaseController
  helper_method :form

  before_action :redirect_to_next_step, only: %i[create]

  def create
    document = form.valid_application_form
    vacancy.application_form.attach(document)
    request_event.trigger(
      :application_form_created,
      vacancy_id: StringAnonymiser.new(vacancy.id),
      name: document.original_filename,
      size: document.size,
      content_type: document.content_type,
    )

    render :show
  end

  def destroy
    document = vacancy.application_form
    document.purge_later

    request_event.trigger(
      :application_form_deleted,
      vacancy_id: StringAnonymiser.new(vacancy.id),
      name: document.filename,
      size: document.byte_size,
      content_type: document.content_type,
    )

    redirect_to organisation_job_application_forms_path(vacancy.id), flash: {
      success: t("jobs.file_delete_success_message", filename: document.filename),
    }
  end

  private

  def step
    :applying_for_the_job_details
  end

  def form
    @form ||= Publishers::JobListing::ApplyingForTheJobDetailsForm.new(applying_for_the_job_details_form_params, vacancy)
  end

  def applying_for_the_job_details_form_params
    (params[:publishers_job_listing_applying_for_the_job_details_form] || params)
          .permit(:application_form, :application_link, :contact_email, :contact_number, :personal_statement_guidance, :school_visits, :how_to_apply)
          .merge(completed_steps: completed_steps, current_organisation: current_organisation)
  end

  def redirect_to_next_step
    return if applying_for_the_job_details_form_params[:application_form]

    vacancy.update(completed_steps: completed_steps)
    if session[:current_step] == :review
      redirect_updated_job_with_message
    else
      redirect_to organisation_job_documents_path(vacancy.id)
    end
  end
end
