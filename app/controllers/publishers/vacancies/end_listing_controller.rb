class Publishers::Vacancies::EndListingController < Publishers::Vacancies::BaseController
  helper_method :form, :vacancy

  def update
    if form.valid?
      vacancy.update(form_params.merge(expires_at: Time.current))
      update_google_index(vacancy)
      SendJobListingEndedEarlyNotificationJob.new.perform(vacancy)
      redirect_to jobs_with_type_organisation_path(:expired), success: t(".success", job_title: vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form
    @form ||= Publishers::JobListing::EndListingForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "show"
      {}
    when "update"
      form_params
    end
  end

  def form_params
    params.require(:publishers_job_listing_end_listing_form).permit(:end_listing_reason, :candidate_hired_from)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.live.find(params[:job_id])
  end
end
