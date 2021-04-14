class Publishers::Vacancies::ExtendDeadlineController < Publishers::Vacancies::BaseController
  helper_method :form, :vacancy

  def update
    return redirect_to organisation_job_job_applications_path(vacancy.id) if params[:commit] == t("buttons.cancel")

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
      { starts_on: vacancy.starts_on, starts_asap: vacancy.starts_asap }
    when "update"
      form_params
    end
  end

  def form_params
    params.require(:publishers_job_listing_extend_deadline_form)
          .permit(:expires_on, :expiry_time, :starts_on, :starts_asap)
          .merge(previous_deadline: vacancy.expires_at)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.published.where("publish_on <= ?", Date.current).find(params[:job_id])
  end
end
