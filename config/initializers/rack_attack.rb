# Throttle counters and fail2ban strikes/bans are stored in Rack::Attack.cache, which defaults to
# Rails.cache — Redis in production, so state is shared across all app instances.

# Allow rack_attack to use Rails's remote_ip, which resolves the real client IP via the trusted
# proxy chain. As we are behind a CDN, Rack's default ip could return the CDN node's address,
# making all clients behind that node share the same throttle counters and IP bans.
class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env["action_dispatch.remote_ip"] || ip).to_s
    end
  end

  ##########################################################################################################################
  # CONSTANTS DEFINITIONS
  # Since this is instantiated once at boot time, we can define constants here to avoid re-evaluating them on every request.
  ##########################################################################################################################

  BLOCKED_IPS = ENV.fetch("RACK_ATTACK_BLOCKED_IPS", "").split(",").map(&:strip).freeze # Array of IPs to block
  blocklist("block all requests from a banned list of remote IPs") do |request|
    BLOCKED_IPS.include?(request.remote_ip)
  end

  ATS_API_PATH_PREFIX = "/ats-api/".freeze
  OIDC_CALLBACK_PATHS = %w[/jobseekers/auth/govuk_one_login/callback /auth/dfe /auth/dfe/callback].freeze
  JOBSEEKER_SIGN_IN_PATH = "/jobseekers/sign-in".freeze
  # Covers the login key create/consume actions and the account transfer endpoints
  FALLBACK_AUTH_PATH_PREFIXES = %w[
    /jobseekers/login_keys
    /publishers/login_keys
    /support-users/fallback_sessions
    /jobseekers/request_account_transfer_email
    /jobseekers/account_transfer
  ].freeze

  # A single combined counter across ALL auth endpoints. Deliberately looser than the per-endpoint
  # throttles below on logins/fallback (5/min = 50/10min), so on those endpoints fail2ban only fires
  # for clients ignoring 429s. Note it is *tighter* than the OIDC throttle (15/min = 150/10min): heavy
  # OIDC callback volume from one IP can trip the ban even while within that throttle. That is
  # accepted, as the ban is auth-scoped (the IP can still browse the rest of the site).
  FAIL2BAN_MAXRETRY = 10 # Ban an IP after this many auth requests...
  FAIL2BAN_FINDTIME = 10.minutes # ...within this window...
  FAIL2BAN_BANTIME = 1.hour # ...for this long.

  ####################################################################################################################
  # AUTH ENDPOINTS FAIL2BAN PROTECTION
  # Prevent brute-forcing of logins, OIDC authorization codes and magic links by banning IPs that repeatedly hit auth
  # endpoints.
  #
  # This fail2ban blocklist and the per-endpoint auth throttles further below are COMPLEMENTARY layers,
  # not redundant. Rack::Attack runs safelist -> blocklist -> throttle, so the two count independently:
  #   - Throttles give graceful, resettable, per-endpoint rate caps (returning 429). They cap the rate
  #     but never stop a persistent attacker, who can keep grinding at the throttle limit indefinitely.
  #   - Fail2ban is the hard combined backstop: it bans IPs that ignore those 429s and hammer auth,
  #     and stops the burst -> back-off -> resume pattern that throttles alone allow. Once banned, the
  #     blocklist short-circuits so the throttles no longer run for that IP.
  ####################################################################################################################

  # Whether a request targets one of our authentication endpoints (union of the auth throttle matchers).
  # Used to gate the fail2ban blocklist so that only auth requests count towards the ban, and non-auth traffic is never blocked.
  # It also saves us from having to query the ban cache for every request, since the blocklist is checked
  # first and only hits the cache if auth_request? returns true.
  def self.auth_request?(request)
    (OIDC_CALLBACK_PATHS.include?(request.path) && request.get?) ||
      (request.path == JOBSEEKER_SIGN_IN_PATH && request.post?) ||
      (request.post? && request.path.start_with?(*FALLBACK_AUTH_PATH_PREFIXES))
  end

  # Allow2Ban lets requests through while counting strikes, and bans once FAIL2BAN_MAXRETRY auth
  # requests are seen within FAIL2BAN_FINDTIME. The ban is auth-scoped (gated on auth_request?):
  # a shared IP (e.g. a school NAT) that trips the limit can still browse the rest of the site.
  blocklist("fail2ban auth brute-forcers") do |request|
    next false unless auth_request?(request)

    Allow2Ban.filter(request.remote_ip, maxretry: FAIL2BAN_MAXRETRY, findtime: FAIL2BAN_FINDTIME, bantime: FAIL2BAN_BANTIME) do
      true # already established this is an auth request, so it counts as a strike
    end
  end
end

####################################################################################################################
# GENERAL THROTTLING
# Throttling of requests to prevent abuse and DoS attacks. ATS API clients have their own dedicated throttle below.
####################################################################################################################

# Throttle general requests by IP
general_throttle = lambda do |request|
  request.remote_ip unless request.path.start_with?(Rack::Attack::ATS_API_PATH_PREFIX) # ATS API clients have their own dedicated throttle below
end
Rack::Attack.throttle("requests by remote ip per 4 secs", limit: 10, period: 4, &general_throttle) # Allow 10 requests in 4 seconds (2.5 req/sec)
Rack::Attack.throttle("requests by remote ip per minute", limit: 105, period: 60, &general_throttle) # Allow 105 requests in 1 minute (1.75 req/sec over 1 minute)
Rack::Attack.throttle("requests by remote ip per 10 minutes", limit: 900, period: 600, &general_throttle) # Allow 900 requests in 10 minutes (1.5 req/sec over 10 minutes)
Rack::Attack.throttle("requests by remote ip per hour", limit: 4500, period: 3600, &general_throttle) # Allow 4500 requests in 1 hour (1.25 req/sec over an hour)
Rack::Attack.throttle("requests by remote ip per 12 hours", limit: 43_200, period: 43_200, &general_throttle) # Allow 43200 requests in 12 hours (1 req/sec over 12 hours)

####################################################################################################################
# ATS API CLIENT THROTTLING
# More relaxed throttling for ATS API clients, keyed by API key (falling back to IP for keyless requests).
####################################################################################################################

# "X-Api-Key" appears in the Rack env as "HTTP_X_API_KEY".
Rack::Attack.throttle("ATS API requests by client", limit: 600, period: 60) do |request|
  if request.path.start_with?(Rack::Attack::ATS_API_PATH_PREFIX)
    request.get_header("HTTP_X_API_KEY").presence || request.remote_ip
  end
end

####################################################################################################################
# AUTH ENDPOINTS THROTTLING
# Throttling of authentication endpoints to prevent brute-forcing of logins, OIDC authorization codes and magic links.
####################################################################################################################

# Throttle OIDC authentication callback endpoints (GOV.UK One Login and DfE Sign In) by IP to
# prevent brute-forcing of authorization codes
Rack::Attack.throttle("limit OIDC auth callbacks by IP", limit: 15, period: 60) do |request|
  if Rack::Attack::OIDC_CALLBACK_PATHS.include?(request.path) && request.get?
    request.remote_ip
  end
end

# Throttle login attempts for jobseeker fallback auth by IP
Rack::Attack.throttle("limit jobseeker logins by IP", limit: 5, period: 60) do |request|
  if request.path == Rack::Attack::JOBSEEKER_SIGN_IN_PATH && request.post?
    request.remote_ip
  end
end

# Throttle login attempts for jobseeker fallback auth by email
Rack::Attack.throttle("limit jobseeker logins by email", limit: 5, period: 60) do |request|
  if request.path == Rack::Attack::JOBSEEKER_SIGN_IN_PATH && request.post?
    jobseeker_params = request.params["jobseeker"]
    jobseeker_params["email"].to_s.downcase.gsub(/\s+/, "").presence if jobseeker_params.is_a?(Hash)
  end
end

# Throttle email-based fallback auth endpoints (magic links, fallback sessions, account transfers) by IP
# to prevent email bombing and brute-forcing of login keys/codes
Rack::Attack.throttle("limit fallback auth requests by IP", limit: 5, period: 60) do |request|
  if request.post? && request.path.start_with?(*Rack::Attack::FALLBACK_AUTH_PATH_PREFIXES)
    request.remote_ip
  end
end

####################################################################################################################
# LOGGING OF THROTTLED AND BLOCKED REQUESTS
# Log all throttled and blocked requests to Rails.logger at WARN level, including the matched rule,
# request ID, remote IP and path.
####################################################################################################################
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _instrumenter_id, payload|
  request = payload[:request]

  Rails.logger.warn("[rack-attack] Throttled request #{request.env['action_dispatch.request_id']} from #{request.remote_ip} to '#{request.fullpath}'",
                    matched: request.env["rack.attack.matched"],
                    ip: request.remote_ip,
                    path: request.fullpath)
end

ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _instrumenter_id, payload|
  request = payload[:request]

  Rails.logger.warn("[rack-attack] Blocked request #{request.env['action_dispatch.request_id']} from #{request.remote_ip} to '#{request.fullpath}'",
                    matched: request.env["rack.attack.matched"],
                    ip: request.remote_ip,
                    path: request.fullpath)
end
