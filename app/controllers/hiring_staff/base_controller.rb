class HiringStaff::BaseController < ApplicationController
  before_action :authenticate

  def authenticate
    return unless authenticate?
    authenticate_or_request_with_http_basic do |name, password|
      name == http_user && password == http_pass
    end
  end

  def authenticate?
    !(Rails.env.development? || Rails.env.test?)
  end

  private def http_user
    if Figaro.env.http_user?
      Figaro.env.http_user
    else
      Rails.logger.warn('Basic auth failed: ENV["HTTP_USER"] expected but not found.')
      nil
    end
  end

  private def http_pass
    if Figaro.env.http_pass?
      Figaro.env.http_pass
    else
      Rails.logger.warn('Basic auth failed: ENV["HTTP_PASS"] expected but not found.')
      nil
    end
  end
end
