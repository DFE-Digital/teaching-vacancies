module AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :authenticated?
  end

  def authenticated?
    session[:session_id].present? && session[:urn].present?
  end
end
