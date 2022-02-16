module ReturnPathTracking
  extend ActiveSupport::Concern

  included do
    include ReturnPathTracking::Helpers

    before_action :store_return_location, if: :storable_location?
    mattr_accessor :authentication_scope
  end

  module Helpers
    extend ActiveSupport::Concern

    included do
      helper_method :redirected?
    end

    # See https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D#storelocation-to-the-rescue
    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    # See https://github.com/heartcombo/devise/wiki/How-To:-%5BRedirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update%5D#storelocation-to-the-rescue
    def store_return_location(location = nil, scope: nil)
      scope ||= authentication_scope
      store_location_for(scope, location || request.fullpath)
    end

    # Devise callback
    def after_sign_out_path_for(resource_or_scope)
      case resource_or_scope
      when :jobseeker, Jobseeker
        new_jobseeker_session_path
      when :publisher, Publisher
        if AuthenticationFallback.enabled?
          new_login_key_path
        else
          URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end").tap { |uri|
            uri.query = {
              post_logout_redirect_uri: new_publisher_session_url,
              id_token_hint: session[:publisher_dsi_token_hint],
            }.to_query
          }.to_s
        end
      end
    end

    def redirected?
      params[:redirected] == "true"
    end
  end
end
