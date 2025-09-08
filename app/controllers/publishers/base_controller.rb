module Publishers
  class BaseController < ApplicationController
    include ReturnPathTracking
    include LoginRequired

    before_action :check_terms_and_conditions
    before_action :check_candidate_profiles_interstitial_acknowledged

    helper_method :current_user

    def check_terms_and_conditions
      redirect_to publishers_terms_and_conditions_path unless current_publisher.accepted_terms_at?
    end

    def check_candidate_profiles_interstitial_acknowledged
      redirect_to publishers_candidate_profiles_interstitial_path unless current_publisher.nil? || current_publisher.acknowledged_candidate_profiles_interstitial?
    end
  end
end
