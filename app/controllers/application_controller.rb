class ApplicationController < ActionController::Base
  SUSPICIOUS_RECAPTCHA_THRESHOLD = 0.5

  before_action :redirect_to_domain

  add_flash_types :success, :danger

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :set_headers
  before_action :set_root_headers

  helper_method :cookies_preference_set?, :referred_from_jobs_path?, :utm_parameters

  include Publishers::AuthenticationConcerns
  include Ip

  def check
    render json: { status: "OK" }, status: :ok
  end

  def not_found
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def strip_empty_checkboxes(fields, form_key = nil)
    params_to_strip = params[form_key].present? ? params[form_key] : params
    fields.each do |field|
      params_to_strip[field] = params_to_strip[field]&.reject(&:blank?) unless params_to_strip[field].is_a?(String)
    end
  end

  def cookies_preference_set?
    cookies["consented-to-cookies"].present?
  end

  def referred_from_jobs_path?
    request_uri = URI(request.referrer || "")
    request.host == request_uri.host && request_uri.path == jobs_path
  end

  def utm_parameters
    params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content)
  end

protected

  def after_sign_in_path_for(_resource)
    jobseekers_saved_jobs_path
  end

  def after_sign_out_path_for(_resource)
    new_jobseeker_session_path
  end

private

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
    request.headers.env["HTTP_USER_AGENT"] != "diego-healthcheck"
  end

  def set_root_headers
    response.set_header("X-Robots-Tag", "index, nofollow") if request.path == root_path
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noindex, nofollow")
  end

  def invalid_recaptcha_score?
    recaptcha_reply["score"] < SUSPICIOUS_RECAPTCHA_THRESHOLD
  end
end
