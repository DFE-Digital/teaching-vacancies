require "google/apis/drive_v3"

class Publishers::Vacancies::ApplicationFormsController < Publishers::Vacancies::BaseController
  helper_method :form

  before_action :redirect_to_next_step, only: %i[create]

  def create
    application_form = form.valid_application_form
    vacancy.application_form.attach(application_form)
    request_event.trigger(
      :application_form_created,
      vacancy_id: StringAnonymiser.new(vacancy.id),
      name: application_form.original_filename,
      size: application_form.size,
      content_type: application_form.content_type,
    )

    render "publishers/vacancies/build/applying_for_the_job_details"
  end

  def destroy
    application_form = vacancy.application_form
    filename = application_form.filename
    application_form.purge_later

    request_event.trigger(
      :application_form_deleted,
      vacancy_id: StringAnonymiser.new(vacancy.id),
      name: application_form.filename,
      size: application_form.byte_size,
      content_type: application_form.content_type,
    )

    redirect_to organisation_job_build_path(vacancy.id, :applying_for_the_job_details, back_to: back_to), flash: {
      success: t("jobs.file_delete_success_message", filename: filename),
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
