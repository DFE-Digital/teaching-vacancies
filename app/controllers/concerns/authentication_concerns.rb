module AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
    helper_method :current_school
  end

  def authenticated?
    session[:session_id].present?
  end

  def current_school
    School.find_by!(urn: session[:urn])
  end
end
