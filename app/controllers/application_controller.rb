class ApplicationController < ActionController::Base
  include Pagy::Backend
  include DfE::Analytics::Requests

  http_basic_authenticate_with name: ENV.fetch("HTTP_BASIC_USER", ""),
                               password: ENV.fetch("HTTP_BASIC_PASSWORD", ""),
                               if: -> { ENV["HTTP_BASIC_PASSWORD"].present? && request.path != "/check" }

  add_flash_types :success, :warning

  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :set_sentry_user
  before_action :redirect_to_canonical_domain, :set_headers
  before_action { EventContext.dfe_analytics_request_event = dfe_analytics_request_event }
  before_action :set_paper_trail_whodunnit

  helper GOVUKDesignSystemFormBuilder::BuilderHelper

  include AbTestable

  def check
    render json: { status: "OK" }, status: :ok
  end

  def not_found(_error = nil)
    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json do
        trigger_api_queried_event(not_found: true) if controller_path == "api/vacancies"
        render json: { error: "Resource not found" }, status: :not_found
      end
      format.all { render status: :not_found, body: nil }
    end
  end

  private

  def show_cookies_banner?
    cookies["consented-to-additional-cookies"].blank?
  end
  helper_method :show_cookies_banner?

  def utm_parameters
    params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content)
  end
  helper_method :utm_parameters

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

    redirect_to status: 301, host: service_domain
  end

  def request_host_is_invalid?
    return false if Rails.env.test? || request_is_healthcheck? || request_from_github_codespace?

    request.host_with_port != service_domain
  end

  def request_is_healthcheck?
    ["diego-healthcheck", "Amazon CloudFront"].include?(request.headers["User-Agent"])
  end

  # Default to Github Codespaces domain if set, otherwise use the standard domain.
  def service_domain
    ENV.fetch("GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN", DOMAIN)
  end

  def request_from_github_codespace?
    Rails.env.development? && request.host_with_port.end_with?(".app.github.dev")
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noindex, nofollow")
  end

  def dfe_analytics_request_event
    DfeAnalyticsRequestEvent.new(request, response, session, current_jobseeker, current_publisher, current_support_user)
  end

  def current_organisation
    @current_organisation ||= Organisation.find_by(id: session[:publisher_organisation_id])
  end
  helper_method :current_organisation

  def user_for_paper_trail
    current_publisher || current_support_user
  end

  def set_sentry_user
    fail_safe do
      user = current_publisher || current_support_user || current_jobseeker
      return unless user

      Sentry.set_user(id: user.id, "User Type": user.class.name)
    end
  end

  # Current user is required by the DfE::Analytics::Event gem.
  def current_user
    current_publisher || current_support_user || current_jobseeker
  end
end
