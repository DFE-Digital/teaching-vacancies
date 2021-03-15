# Allow rack_attack to use Rails's remote_ip (as we are behind a CDN)
class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env["action_dispatch.remote_ip"] || ip).to_s
    end
  end
end

# Throttle general requests by IP
Rack::Attack.throttle("requests by remote ip", limit: 10, period: 4, &:remote_ip)

# Throttle login/password reset attempts for jobseekers
Rack::Attack.throttle("limit jobseeker logins/password resets", limit: 5, period: 60) do |request|
  if %w[/jobseekers/password /jobseekers/sign_in].include?(request.path) && request.post?
    request.params["jobseeker[email]"].to_s.downcase.gsub(/\s+/, "")
  end
end

# Throttle login attempts for publisher fallback auth
Rack::Attack.throttle("limit publisher fallback logins", limit: 3, period: 60) do |request|
  if request.path == "/publishers/auth/email/sessions/check-your-email" && request.post?
    request.params["publisher[email]"].to_s.downcase.gsub(/\s+/, "")
  end
end

ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, request_id, payload|
  remote_ip = payload[:request].remote_ip
  path = payload[:request].fullpath

  Rails.logger.warn("[rack-attack] Throttled request #{request_id} from #{remote_ip} to '#{path}'")
end
