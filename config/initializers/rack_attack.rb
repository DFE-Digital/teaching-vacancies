# Throttle counters and fail2ban strikes/bans are stored in Rack::Attack.cache, which defaults to
# Rails.cache — Redis in production, so state is shared across all app instances.

# Send a Retry-After header on 429s so throttled clients (in particular ATS API partners) know how
# long to back off for, instead of retrying blind.
Rack::Attack.throttled_response_retry_after_header = true

####################################################################################################################
# CLOUDFRONT WAF
# A CloudFront WAF rate-based rule sits in front of this app and blocks any IP exceeding 900
# requests per 5 minutes (3 req/sec) — see terraform/app/modules/cloudfront/main.tf and
# `waf_ip_rate_limit` in terraform/workspace-variables/*.tfvars.json. Notes for rules added here:
#   - A rule looser than 3 req/sec can never fire for origin traffic, since the edge blocks first.
#   - The WAF only aggregates by IP, so anything keyed by API key, email or path has to live here.
#   - The WAF blocks with an opaque edge 403; our throttles are scoped 429s, logged below.
####################################################################################################################

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

  # Kubernetes liveness/startup probes hit this path every 5 seconds from the node's kubelet IP, so
  # all pods on a node would otherwise share one throttle counter against it. It does no work
  # (renders a static JSON body, no DB access), so it's safe to exempt entirely — safelisting it
  # also means a blocklisted IP can still reach it.
  HEALTH_CHECK_PATH = "/check".freeze
  safelist("health check probes") do |request|
    request.path == HEALTH_CHECK_PATH
  end

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

  # A single combined counter across ALL auth endpoints (OIDC callbacks, jobseeker sign-in and the
  # fallback auth POSTs). 50 auth requests in 10 minutes is far beyond any individual legitimate user
  # — a normal login is a single callback or form POST, so a human would need a submission every ~12s
  # for 10 minutes straight — so this only bites automated brute-forcing. It sits at or below the
  # per-endpoint throttles' 10-minute allowances (auth attempts 5/min = 50/10min; OIDC 15/min =
  # 150/10min), so fail2ban, not the throttles, is the binding limit on sustained auth volume.
  FAIL2BAN_MAXRETRY = 50 # Ban an IP after this many auth requests...
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

  # Whether a request targets one of our OIDC authentication callback endpoints (GET).
  def self.oidc_callback_request?(request)
    request.get? && OIDC_CALLBACK_PATHS.include?(request.path)
  end

  # Whether a request targets one of our credential-based auth endpoints (jobseeker sign-in or the
  # fallback auth POSTs — login keys, fallback sessions, account transfers).
  def self.credential_auth_request?(request)
    request.post? &&
      (request.path == JOBSEEKER_SIGN_IN_PATH || request.path.start_with?(*FALLBACK_AUTH_PATH_PREFIXES))
  end

  # Whether a request targets one of our authentication endpoints (union of the auth throttle matchers).
  # Used to gate the fail2ban blocklist so that only auth requests count towards the ban, and non-auth traffic is never blocked.
  # It also saves us from having to query the ban cache for every request, since the blocklist is checked
  # first and only hits the cache if auth_request? returns true.
  def self.auth_request?(request)
    oidc_callback_request?(request) || credential_auth_request?(request)
  end

  # Allow2Ban lets requests through while counting strikes, and bans once FAIL2BAN_MAXRETRY auth
  # requests are seen within FAIL2BAN_FINDTIME. The ban is auth-scoped (gated on auth_request?):
  # a shared IP that trips the limit can still browse the rest of the site.
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
Rack::Attack.throttle("requests by remote ip per minute", limit: 105, period: 60, &general_throttle) # Allow 105 requests in 1 minute (1.75 req/sec over 1 minute)
Rack::Attack.throttle("requests by remote ip per hour", limit: 4500, period: 3600, &general_throttle) # Allow 4500 requests in 1 hour (1.25 req/sec over an hour)

####################################################################################################################
# ATS API CLIENT THROTTLING
# More relaxed throttling for ATS API clients, keyed by API key (falling back to IP for keyless requests).
#
# Limit is 150/min rather than the CloudFront WAF's ~180/min average (900 per 5 min, aggregated by
# IP) so a client relying on their documented allowance gets a Rails 429 (logged, with Retry-After)
# instead of an opaque CloudFront 403 with nothing in our logs. Do not raise this above the WAF
# ceiling — requests beyond it are blocked at the edge regardless of what we allow here.
####################################################################################################################

# "X-Api-Key" appears in the Rack env as "HTTP_X_API_KEY".
Rack::Attack.throttle("ATS API requests by client", limit: 150, period: 60) do |request|
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
  request.remote_ip if Rack::Attack.oidc_callback_request?(request)
end

# Throttle credential-based auth attempts by IP: jobseeker sign-in POSTs and the fallback auth POSTs
# (login keys, fallback sessions, account transfers) share a single counter, since both are the same
# kind of attempt to establish a session and a brute-forcer can otherwise just alternate between them
# to double their effective allowance.
Rack::Attack.throttle("limit auth attempts by IP", limit: 5, period: 60) do |request|
  request.remote_ip if Rack::Attack.credential_auth_request?(request)
end

# Throttle login attempts for jobseeker fallback auth by email
Rack::Attack.throttle("limit jobseeker logins by email", limit: 5, period: 60) do |request|
  if request.path == Rack::Attack::JOBSEEKER_SIGN_IN_PATH && request.post?
    jobseeker_params = request.params["jobseeker"]
    jobseeker_params["email"].to_s.downcase.gsub(/\s+/, "").presence if jobseeker_params.is_a?(Hash)
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
