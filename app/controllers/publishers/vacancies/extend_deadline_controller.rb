class Publishers::Vacancies::ExtendDeadlineController < Publishers::Vacancies::BaseController
  helper_method :vacancy

  def show
    form_class = vacancy.expired? ? Publishers::JobListing::RelistForm : Publishers::JobListing::ExtendDeadlineForm
    @form = form_class.new(
      start_date_type: vacancy.start_date_type,
      starts_on: vacancy.starts_on,
      earliest_start_date: vacancy.earliest_start_date,
      latest_start_date: vacancy.latest_start_date,
      other_start_date_details: vacancy.other_start_date_details,
    )
  end

  def update
    @form = Publishers::JobListing::ExtendDeadlineForm.new(form_params)
    if @form.valid?
      vacancy.update(@form.attributes_to_save)
      update_google_index(vacancy)
      redirect_to organisation_jobs_with_type_path(:published), success: t(".success", job_title: vacancy.job_title)
    else
      render :show
    end
  end

  def relist
    @form = Publishers::JobListing::RelistForm.new(relist_params)
    if @form.valid?
      vacancy.update(@form.attributes_to_save)
      update_google_index(vacancy)
      redirect_to organisation_job_summary_path(vacancy.id), success: t(".success", job_title: vacancy.job_title)
    else
      render :show
    end
  end

  private

  def common_params
    %i[expires_at expiry_time start_date_type starts_on earliest_start_date latest_start_date other_start_date_details extension_reason other_extension_reason_details]
  end

  def form_params
    params.require(:publishers_job_listing_extend_deadline_form)
          .permit(*common_params)
          .merge(previous_deadline: vacancy.expires_at)
  end

  def relist_params
    params.require(:publishers_job_listing_relist_form)
          .permit(*(common_params + %i[publish_on publish_on_day]))
          .merge(previous_deadline: vacancy.expires_at)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.published.listed.find(params[:job_id])
  end
end
