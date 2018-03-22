class HiringStaff::BaseController < ApplicationController
  before_action :authenticate

  def authenticate
    return unless authenticate_hiring_staff?
    authenticate_or_request_with_http_basic('Hiring Staff') do |name, password|
      if name == benwick_http_user && password == benwick_http_pass
        true
      elsif name == http_user && password == http_pass
        true
      end
    end
  end

  def authenticate_hiring_staff?
    !(Rails.env.development? || Rails.env.test?)
  end

  private def http_user
    if Figaro.env.hiring_staff_http_user?
      Figaro.env.hiring_staff_http_user
    else
      Rails.logger.warn('Basic auth failed: ENV["hiring_staff_http_user"] expected but not found.')
      nil
    end
  end

  private def http_pass
    if Figaro.env.hiring_staff_http_pass?
      Figaro.env.hiring_staff_http_pass
    else
      Rails.logger.warn('Basic auth failed: ENV["hiring_staff_http_pass"] expected but not found.')
      nil
    end
  end

  private def benwick_http_user
    if Figaro.env.benwick_http_user?
      Figaro.env.benwick_http_user
    else
      Rails.logger.warn('Basic auth failed: ENV["benwick_http_user"] expected but not found.')
      nil
    end
  end

  private def benwick_http_pass
    if Figaro.env.benwick_http_pass?
      Figaro.env.benwick_http_pass
    else
      Rails.logger.warn('Basic auth failed: ENV["benwick_http_pass"] expected but not found.')
      nil
    end
  end
end
