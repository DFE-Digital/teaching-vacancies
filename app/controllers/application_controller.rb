class ApplicationController < ActionController::Base
  SUSPICIOUS_RECAPTCHA_THRESHOLD = 0.5

  add_flash_types :success, :danger

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :redirect_to_canonical_domain, :set_headers
  before_action { strip_nested_param_whitespaces(request.params) }

  after_action :trigger_page_visited_event, unless: :request_is_healthcheck?

  helper_method :cookies_preference_set?, :referred_from_jobs_path?, :utm_parameters

  include Publishers::AuthenticationConcerns

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

private

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

  def strip_empty_checkboxes(fields, form_key = nil)
    params_to_strip = params[form_key].present? ? params[form_key] : params
    fields.each do |field|
      params_to_strip[field] = params_to_strip[field]&.reject(&:blank?) if params_to_strip[field].is_a?(Array)
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:session_id] = "#{session.id.to_s[0..7]}…" if session.id
  end

  def redirect_to_canonical_domain
    if request_host_is_invalid?
      redirect_to status: 301, host: DOMAIN
    end
  end

  def request_host_is_invalid?
    !Rails.env.test? && !request_is_healthcheck? && request.host_with_port != DOMAIN
  end

  def request_is_healthcheck?
    ["diego-healthcheck", "Amazon CloudFront"].include?(request.headers["User-Agent"])
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noindex, nofollow")
  end

  def invalid_recaptcha_score?
    recaptcha_reply["score"] < SUSPICIOUS_RECAPTCHA_THRESHOLD
  end

  def strip_nested_param_whitespaces(object)
    # Recursively find strings and strip them of trailing whitespaces
    if object.is_a?(String)
      return object.strip
    elsif object.is_a?(Hash)
      object.each do |key, value|
        object[key] = strip_nested_param_whitespaces(value)
      end
    end

    object
  end

  def request_event
    @request_event ||= RequestEvent.new(request, response, session, current_jobseeker, current_publisher_oid)
  end

  def trigger_page_visited_event
    request_event.trigger(:page_visited)
  end
end
