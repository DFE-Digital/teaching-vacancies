class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :check_staging_auth, except: :check
  before_action :set_headers

  helper_method :current_school

  include AuthenticationConcerns
  include Ip

  def check
    render json: { status: 'OK' }, status: 200
  end

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.json { render json: { error: 'Resource not found' }, status: 404 }
      format.all { render status: 404, body: nil }
    end
  end

  def check_staging_auth
    return unless authenticate?
    authenticate_or_request_with_http_basic('Global') do |name, password|
      name == http_user && password == http_pass
    end
  end

  def current_school
    @current_school ||= School.find_by! urn: session[:urn]
  end

  def authenticate?
    Rails.env.staging?
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

  private def append_info_to_payload(payload)
    super
    payload[:remote_ip] = request_ip
    payload[:session_id] = "#{session.id[0..7]}…" if session.id
  end

  private def set_headers
    response.set_header('X-Robots-Tag', 'none')
  end
end
