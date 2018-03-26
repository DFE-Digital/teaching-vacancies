class HiringStaff::BaseController < ApplicationController
  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_basic('Hiring Staff') do |name, password|
      if name == benwick_http_user && password == benwick_http_pass
        session[:urn] = '110627'
        true
      elsif name == http_user && password == http_pass
        session[:urn] = ENV.fetch('DEFAULT_SCHOOL_URN') { School.first.urn }
        true
      end
    end
  end

  def current_school
    @current_school ||= School.find_by! urn: session[:urn]
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  private def http_user
    Figaro.env.hiring_staff_http_user if Figaro.env.hiring_staff_http_user?
  end

  private def http_pass
    Figaro.env.hiring_staff_http_pass if Figaro.env.hiring_staff_http_pass?
  end

  private def benwick_http_user
    Figaro.env.benwick_http_user if Figaro.env.benwick_http_user?
  end

  private def benwick_http_pass
    Figaro.env.benwick_http_pass if Figaro.env.benwick_http_pass?
  end
end
