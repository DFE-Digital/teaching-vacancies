module Publishers
  class BaseController < ApplicationController
    include ReturnPathTracking
    include LoginRequired

    before_action :check_terms_and_conditions

    helper_method :current_user

    def check_terms_and_conditions
      redirect_to publishers_terms_and_conditions_path unless current_publisher.accepted_terms_at?
    end
  end
end
