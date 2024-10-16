class Publishers::Vacancies::RelistController < Publishers::Vacancies::BaseController
  def create
    vacancy.status = :draft
    @vacancy = CopyVacancy.new(vacancy).call

    @form = Publishers::JobListing::RelistForm.new

    render :edit
  end

  def update
    @form = Publishers::JobListing::RelistForm.new(relist_params)
    if @form.valid?
      vacancy.update(@form.attributes_to_save.merge(status: :published))
      update_google_index(vacancy)
      redirect_to organisation_job_summary_path(vacancy.id), success: t(".success", job_title: vacancy.job_title)
    else
      @vacancy = vacancy
      render :edit
    end
  end

  private

  def relist_params
    params.require(:publishers_job_listing_relist_form)
          .permit(:expires_at, :expiry_time, :publish_on, :publish_on_day, :extension_reason, :other_extension_reason_details)
  end
end
