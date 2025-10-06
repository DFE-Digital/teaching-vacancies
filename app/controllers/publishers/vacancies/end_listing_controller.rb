class Publishers::Vacancies::EndListingController < Publishers::Vacancies::BaseController
  before_action :set_vacancy

  def show
    @form = Publishers::JobListing::EndListingForm.new
  end

  def update
    @form = Publishers::JobListing::EndListingForm.new(form_params)
    if @form.valid?
      @vacancy.update!(form_params.merge(expires_at: Time.current))
      update_google_index(@vacancy)
      SendJobListingEndedEarlyNotificationJob.perform_later(@vacancy)
      redirect_to organisation_job_path(@vacancy.id), success: t(".success", job_title: @vacancy.job_title)
    else
      render :show
    end
  end

  private

  def form_params
    (params[:publishers_job_listing_end_listing_form] || params).permit(:hired_status, :listed_elsewhere)
  end

  def set_vacancy
    @vacancy = current_organisation.all_vacancies.live.find(params[:job_id])
  end
end
