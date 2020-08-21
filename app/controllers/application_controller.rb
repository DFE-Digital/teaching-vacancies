class ApplicationController < ActionController::Base
  add_flash_types :success, :danger

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  # before_action :check_staging_auth, except: :check
  before_action :set_headers
  before_action :detect_device_format
  before_action :set_root_headers

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

  # rubocop:disable Rails/UnknownEnv
  def authenticate?
    Rails.env.staging?
  end
  # rubocop:enable Rails/UnknownEnv

  def detect_device_format
    request.variant = :phone if browser.device.mobile?
  end

  def current_session_id
    session.to_h['session_id']
  end

  def strip_empty_checkboxes(form_key, fields)
    if params[form_key].present?
      fields.each do |field|
        params[form_key][field] = params[form_key][field]&.reject(&:blank?)
      end
    end
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
    payload[:session_id] = "#{session.id[0..7]}…" if session.id
  end

  def set_root_headers
    response.set_header('X-Robots-Tag', 'index, nofollow') if request.path == root_path
  end

  def set_headers
    response.set_header('X-Robots-Tag', 'noindex, nofollow')
  end
end
