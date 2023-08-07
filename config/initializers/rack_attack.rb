# Allow rack_attack to use Rails's remote_ip (as we are behind a CDN)
class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env["action_dispatch.remote_ip"] || ip).to_s
    end
  end

  BLOCKED_IPS = ENV.fetch("RACK_ATTACK_BLOCKED_IPS", "").split(",").map(&:strip).freeze # Array of IPs to block
  blocklist("block all request from a banned list of remote IPs") do |request|
    BLOCKED_IPS.include?(request.remote_ip)
  end
end

# Override response to return 204 No Content (instead of 429) so our monitoring doesn't count it
# as a failed request
Rack::Attack.throttled_responder = lambda do |_request|
  [204, {}, ["\n"]]
end

# Throttle general requests by IP
Rack::Attack.throttle("requests by remote ip per 4 secs", limit: 10, period: 4, &:remote_ip) # Allow 10 requests in 4 seconds (2.5 req/sec)
Rack::Attack.throttle("requests by remote ip per minute", limit: 105, period: 60, &:remote_ip) # Allow 105 requests in 1 minute (1.75 req/sec over 1 minute)
Rack::Attack.throttle("requests by remote ip per 10 minutes", limit: 900, period: 600, &:remote_ip) # Allow 900 requests in 10 minutes (1.5 req/sec over 10 minutes)
Rack::Attack.throttle("requests by remote ip per hour", limit: 4500, period: 3600, &:remote_ip) # Allow 4500 requests in 1 hour (1.25 req/sec over an hour)
Rack::Attack.throttle("requests by remote ip per 12 hours", limit: 43_200, period: 43_200, &:remote_ip) # Allow 43200 requests in 12 hours (1 req/sec over 12 hours)

# Throttle login/password reset attempts for jobseekers by IP
Rack::Attack.throttle("limit jobseeker logins/password resets by IP", limit: 5, period: 60) do |request|
  if %w[/jobseekers/password /jobseekers/sign-in].include?(request.path) && request.post?
    request.remote_ip
  end
end

# Throttle login/password reset attempts for jobseekers by email
Rack::Attack.throttle("limit jobseeker logins/password resets by email", limit: 5, period: 60) do |request|
  if %w[/jobseekers/password /jobseekers/sign-in].include?(request.path) && request.post?
    request.params["jobseeker[email]"].to_s.downcase.gsub(/\s+/, "")
  end
end

# Throttle login attempts for publisher fallback auth by IP
Rack::Attack.throttle("limit publisher fallback logins by IP", limit: 3, period: 60) do |request|
  if request.path == "/publishers/auth/email/sessions/check-your-email" && request.post?
    request.remote_ip
  end
end

# Throttle login attempts for publisher fallback auth by email
Rack::Attack.throttle("limit publisher fallback logins by email", limit: 3, period: 60) do |request|
  if request.path == "/publishers/auth/email/sessions/check-your-email" && request.post?
    request.params["publisher[email]"].to_s.downcase.gsub(/\s+/, "")
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, request_id, payload|
  remote_ip = payload[:request].remote_ip
  path = payload[:request].fullpath

  Rails.logger.warn("[rack-attack] Throttled request #{request_id} from #{remote_ip} to '#{path}'")
end
