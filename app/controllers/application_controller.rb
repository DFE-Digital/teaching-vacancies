class ApplicationController < ActionController::Base
  before_action :redirect_to_domain

  add_flash_types :success, :danger

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # before_action :check_staging_auth, except: :check
  before_action :set_headers
  before_action :detect_device_format
  before_action :set_root_headers

  helper_method :cookies_preference_set?, :referred_from_jobs_path?, :utm_parameters

  include AuthenticationConcerns
  include Ip

  def check
    render json: { status: 'OK' }, status: :ok
  end

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def check_staging_auth
    return unless authenticate?

    authenticate_or_request_with_http_basic('Global') do |name, password|
      name == http_user && password == http_pass
    end
  end

  def authenticate?
    Rails.env.staging?
  end

  def detect_device_format
    request.variant = :phone if browser.device.mobile?
  end

  def current_session_id
    session.to_h['session_id']
  end

  def strip_empty_checkboxes(form_key, fields)
    if params[form_key].present?
      fields.each do |field|
        params[form_key][field] = params[form_key][field]&.reject(&:blank?) unless params[form_key][field].is_a?(String)
      end
    else
      fields.each do |field|
        params[field] = params[field]&.reject(&:blank?) unless params[field].is_a?(String)
      end
    end
  end

  def cookies_preference_set?
    cookies['consented-to-cookies'].present?
  end

  def referred_from_jobs_path?
    request_uri = URI(request.referrer || '')
    request.host == request_uri.host && request_uri.path == jobs_path
  end

  def utm_parameters
    params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content)
  end

private

  def http_user
    if Figaro.env.http_user?
      Figaro.env.http_user
    else
      Rails.logger.warn('Basic auth failed: ENV["HTTP_USER"] expected but not found.')
      nil
    end
  end

  def http_pass
    if Figaro.env.http_pass?
      Figaro.env.http_pass
    else
      Rails.logger.warn('Basic auth failed: ENV["HTTP_PASS"] expected but not found.')
      nil
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:remote_ip] = request_ip
    payload[:session_id] = "#{session.id.to_s[0..7]}…" if session.id
  end

  def redirect_to_domain
    if request_host_is_invalid?
      redirect_to status: 301, host: DOMAIN
    end
  end

  def request_host_is_invalid?
    !Rails.env.test? && request_is_not_paas_healthcheck? && request.host_with_port != DOMAIN
  end

  def request_is_not_paas_healthcheck?
    request.headers.env['HTTP_USER_AGENT'] != 'diego-healthcheck'
  end

  def set_root_headers
    response.set_header('X-Robots-Tag', 'index, nofollow') if request.path == root_path
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noindex, nofollow')
  end
end
