module Publishers
  class Publishers::BaseController < ApplicationController
    include LoginRequired

    before_action :check_terms_and_conditions
    before_action :check_ats_interstitial_acknowledged

    helper_method :current_user

    def check_terms_and_conditions
      redirect_to publishers_terms_and_conditions_path unless current_publisher.accepted_terms_at?
    end

    def check_ats_interstitial_acknowledged
      return if current_publisher.nil? || current_publisher.acknowledged_ats_and_religious_form_interstitial?

      redirect_to publishers_ats_interstitial_path
    end
  end
end
