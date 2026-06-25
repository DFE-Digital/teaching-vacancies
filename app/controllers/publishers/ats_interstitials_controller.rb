class Publishers::AtsInterstitialsController < Publishers::BaseController
  def show
    @organisation = current_organisation
    @variant = @organisation.ats_interstitial_variant
  end

  def update
    if current_publisher.update(acknowledged_ats_and_religious_form_interstitial: true)
      redirect_to organisation_jobs_with_type_path
    else
      @organisation = current_organisation
      @variant = @organisation.ats_interstitial_variant
      render :show
    end
  end
end
