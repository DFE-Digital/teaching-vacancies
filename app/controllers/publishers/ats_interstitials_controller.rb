class Publishers::AtsInterstitialsController < Publishers::BaseController
  skip_before_action :check_ats_interstitial_acknowledged, only: %i[show update]

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
