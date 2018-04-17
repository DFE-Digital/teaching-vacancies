module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def current_user
    session[:session_id].present? && session[:urn].present?
  end
end
