class Publishers::CandidateProfilesInterstitialsController < Publishers::BaseController
  skip_before_action :check_candidate_profiles_interstitial_acknowledged, only: %i[show]
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show
    current_publisher.update(acknowledged_candidate_profiles_interstitial: true)
  end
end
