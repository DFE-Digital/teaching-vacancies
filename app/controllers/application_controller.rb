puts "test"

class ApplicationController < ActionController::Base
  SUSPICIOUS_RECAPTCHA_THRESHOLD = 0.5
  VALID_CLICK_EVENT_TYPES = %w[vacancy_save_to_account_clicked].freeze

  add_flash_types :success, :warning

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :redirect_to_canonical_domain, :set_headers
  before_action :store_jobseeker_redirect_to!, if: -> { redirect_to_param.present? }
  before_action :trigger_click_event, if: -> { click_event_param.present? }
  before_action { EventContext.request_event = request_event }

  after_action :trigger_page_visited_event, unless: :request_is_healthcheck?

  helper_method :cookies_preference_set?, :referred_from_jobs_path?, :user_type, :utm_parameters, :current_variant?

  include Publishers::AuthenticationConcerns
  include DeviseFlashConcerns
  include AbTestable

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

  def user_type
    if jobseeker_signed_in?
      :jobseeker
    elsif publisher_signed_in?
      :publisher
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
    return unless request_host_is_invalid?

    redirect_to status: 301, host: DOMAIN
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

  def recaptcha_is_invalid?(model)
    !verify_recaptcha(model: model, action: controller_name, minimum_score: SUSPICIOUS_RECAPTCHA_THRESHOLD) && recaptcha_reply
  end

  def request_event
    RequestEvent.new(request, response, session, current_jobseeker, current_publisher)
  end

  def trigger_page_visited_event
    request_event.trigger(:page_visited)
  end

  def store_jobseeker_redirect_to!
    store_location_for(:jobseeker, redirect_to_param)
  end

  def redirect_to_param
    params[:redirect_to]
  end

  def trigger_click_event
    return unless VALID_CLICK_EVENT_TYPES.include?(click_event_param)

    request_event.trigger(click_event_param.to_sym, click_event_data_params.to_h)
  end

  def click_event_param
    params[:click_event]
  end

  def click_event_data_params
    # Any params that might be present must be explicitly permitted in order to convert to hash
    params[:click_event_data]&.permit(:vacancy_id)
  end
end
