module Authenticated
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_scope!
    mattr_accessor :authentication_scope
    helper_method :user_type
  end

  private

  def authenticate_scope!
    require_scope
    send("authenticate_#{authentication_scope}!", { recall: "home##{authentication_scope}_forced_login" })
  end

  def require_scope
    raise "Please set `authentication_scope` with this controller's scope" if authentication_scope.blank?
  end

  def user_type
    if jobseeker_signed_in?
      :jobseeker
    elsif publisher_signed_in?
      :publisher
    end
  end
end
