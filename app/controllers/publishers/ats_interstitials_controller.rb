class Publishers::AtsInterstitialsController < Publishers::BaseController
  skip_before_action :check_ats_interstitial_acknowledged
  def show
    @school = current_organisation
    @variant = @school.ats_interstitial_variant
  end

  def update
    current_publisher.update!(acknowledged_ats_and_religious_form_interstitial: true)
    redirect_to organisation_jobs_with_type_path
  end
end
