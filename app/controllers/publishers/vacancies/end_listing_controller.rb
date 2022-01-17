class Publishers::Vacancies::EndListingController < Publishers::Vacancies::BaseController
  helper_method :form, :vacancy

  def update
    if form.valid?
      vacancy.update(form_params.merge(expires_at: Time.current))
      update_google_index(vacancy)
      SendJobListingEndedEarlyNotificationJob.new.perform(vacancy)
      redirect_to organisation_job_path(vacancy.id), success: t(".success", job_title: vacancy.job_title)
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
    (params[:publishers_job_listing_end_listing_form] || params).permit(:hired_status, :listed_elsewhere)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.live.find(params[:job_id])
  end
end
