class Publishers::BaseController < ApplicationController
  include ReturnPathTracking
  include Authenticated

  self.authentication_scope = :publisher

  before_action :check_terms_and_conditions

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_publisher.accepted_terms_at?
  end
end
