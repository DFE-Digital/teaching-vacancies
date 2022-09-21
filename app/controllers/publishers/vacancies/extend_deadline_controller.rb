class Publishers::Vacancies::ExtendDeadlineController < Publishers::Vacancies::BaseController
  helper_method :form, :vacancy

  def update
    if form.valid?
      vacancy.update(form.attributes_to_save)
      update_google_index(vacancy)
      redirect_to jobs_with_type_organisation_path(:published), success: t(".success", job_title: vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form
    @form ||= Publishers::JobListing::ExtendDeadlineForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "show"
      {
        start_date_type: vacancy.start_date_type,
        starts_on: vacancy.starts_on,
        earliest_start_date: vacancy.earliest_start_date,
        latest_start_date: vacancy.latest_start_date,
        other_start_date_details: vacancy.other_start_date_details,
      }
    when "update"
      form_params
    end
  end

  def form_params
    params.require(:publishers_job_listing_extend_deadline_form)
          .permit(:expires_at, :expiry_time, :start_date_type, :starts_on, :earliest_start_date, :latest_start_date, :other_start_date_details)
          .merge(previous_deadline: vacancy.expires_at)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.published.find(params[:job_id])
  end
end
