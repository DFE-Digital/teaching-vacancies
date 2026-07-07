require "rails_helper"

RSpec.describe "Rack::Attack" do
  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after do
    Rack::Attack.cache.store = Rails.cache
  end

  def build_request(path, method: "GET", ip: "1.2.3.4", api_key: nil, params: nil)
    env_options = { method: method, "action_dispatch.remote_ip" => ip }
    env_options["HTTP_X_API_KEY"] = api_key if api_key
    env_options[:params] = params if params
    Rack::Attack::Request.new(Rack::MockRequest.env_for(path, env_options))
  end

  describe "general requests throttles" do
    let(:throttle) { Rack::Attack.throttles["requests by remote ip per 4 secs"] }

    it "keys requests by remote IP" do
      expect(throttle.block.call(build_request("/jobs"))).to eq("1.2.3.4")
    end

    it "exempts ATS API requests" do
      expect(throttle.block.call(build_request("/ats-api/v1/vacancies"))).to be_nil
    end
  end

  describe "ATS API throttle" do
    let(:throttle) { Rack::Attack.throttles["ATS API requests by client"] }

    it "allows more requests than the general throttles" do
      expect(throttle.limit).to eq(600)
      expect(throttle.period).to eq(60)
    end

    it "keys ATS API requests by API key" do
      request = build_request("/ats-api/v1/vacancies", api_key: "api-key-123")
      expect(throttle.block.call(request)).to eq("api-key-123")
    end

    it "keys keyless ATS API requests by remote IP" do
      expect(throttle.block.call(build_request("/ats-api/v1/vacancies"))).to eq("1.2.3.4")
    end

    it "does not match requests outside the ATS API" do
      expect(throttle.block.call(build_request("/jobs", api_key: "api-key-123"))).to be_nil
    end
  end

  describe "OIDC auth callbacks throttle" do
    let(:throttle) { Rack::Attack.throttles["limit OIDC auth callbacks by IP"] }

    it "keys GET requests to the OIDC callback endpoints by remote IP" do
      Rack::Attack::OIDC_CALLBACK_PATHS.each do |path|
        expect(throttle.block.call(build_request(path))).to eq("1.2.3.4")
      end
    end

    it "does not match other HTTP methods" do
      expect(throttle.block.call(build_request("/auth/dfe", method: "POST"))).to be_nil
    end

    it "does not match other paths" do
      expect(throttle.block.call(build_request("/jobs"))).to be_nil
    end
  end

  describe "jobseeker logins by IP throttle" do
    let(:throttle) { Rack::Attack.throttles["limit jobseeker logins by IP"] }

    it "keys POST requests to the jobseeker sign-in endpoint by remote IP" do
      request = build_request("/jobseekers/sign-in", method: "POST")
      expect(throttle.block.call(request)).to eq("1.2.3.4")
    end

    it "does not match other HTTP methods" do
      expect(throttle.block.call(build_request("/jobseekers/sign-in"))).to be_nil
    end

    it "does not match other paths" do
      expect(throttle.block.call(build_request("/jobs", method: "POST"))).to be_nil
    end
  end

  describe "jobseeker logins by email throttle" do
    let(:throttle) { Rack::Attack.throttles["limit jobseeker logins by email"] }

    it "keys POST requests to the jobseeker sign-in endpoint by normalised email" do
      request = build_request("/jobseekers/sign-in", method: "POST", params: { jobseeker: { email: " Foo@BAR.com " } })
      expect(throttle.block.call(request)).to eq("foo@bar.com")
    end

    it "does not match requests without an email" do
      request = build_request("/jobseekers/sign-in", method: "POST", params: { jobseeker: { password: "secret" } })
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match requests with malformed jobseeker params" do
      request = build_request("/jobseekers/sign-in", method: "POST", params: { jobseeker: "malformed" })
      expect(throttle.block.call(request)).to be_nil
    end

    it "does not match other HTTP methods" do
      expect(throttle.block.call(build_request("/jobseekers/sign-in"))).to be_nil
    end
  end

  describe "fallback auth throttle" do
    let(:throttle) { Rack::Attack.throttles["limit fallback auth requests by IP"] }

    it "keys POST requests to the fallback auth endpoints by remote IP" do
      paths = %w[
        /jobseekers/login_keys
        /publishers/login_keys
        /publishers/login_keys/some-id/consume
        /support-users/fallback_sessions
        /jobseekers/request_account_transfer_email
        /jobseekers/account_transfer
      ]
      paths.each do |path|
        expect(throttle.block.call(build_request(path, method: "POST"))).to eq("1.2.3.4")
      end
    end

    it "does not match other HTTP methods" do
      expect(throttle.block.call(build_request("/jobseekers/login_keys"))).to be_nil
    end

    it "does not match other paths" do
      expect(throttle.block.call(build_request("/jobs", method: "POST"))).to be_nil
    end
  end

  describe "throttled requests" do
    it "returns 429 and logs a warning when a throttle limit is exceeded" do
      allow(Rails.logger).to receive(:warn)

      freeze_time do
        6.times { post "/jobseekers/sign-in", params: { jobseeker: { email: "", password: "" } } }
      end

      expect(response).to have_http_status(:too_many_requests)
      expect(Rails.logger).to have_received(:warn)
        .with(a_string_matching(/\[rack-attack\] Throttled request/),
              hash_including(matched: "limit jobseeker logins by IP", ip: "127.0.0.1", path: "/jobseekers/sign-in"))
    end

    it "does not apply the general throttles to ATS API requests" do
      freeze_time do
        12.times { get "/ats-api/v1/vacancies" }
      end

      expect(response).to have_http_status(:unauthorized)
    end

    it "applies the general throttles to non-ATS API requests" do
      freeze_time do
        11.times { get "/check" }
      end

      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "blocklisted requests" do
    before do
      stub_const("Rack::Attack::BLOCKED_IPS", %w[127.0.0.1])
    end

    it "returns 403 and logs a warning" do
      allow(Rails.logger).to receive(:warn)

      get "/check"

      expect(response).to have_http_status(:forbidden)
      expect(Rails.logger).to have_received(:warn)
        .with(a_string_matching(/\[rack-attack\] Blocked request/),
              hash_including(matched: "block all request from a banned list of remote IPs", ip: "127.0.0.1", path: "/check"))
    end
  end

  describe ".auth_request?" do
    it "is true for authentication requests" do
      expect(Rack::Attack.auth_request?(build_request("/auth/dfe"))).to be(true)
      expect(Rack::Attack.auth_request?(build_request("/jobseekers/sign-in", method: "POST"))).to be(true)
      expect(Rack::Attack.auth_request?(build_request("/jobseekers/login_keys", method: "POST"))).to be(true)
    end

    it "is false for other requests" do
      expect(Rack::Attack.auth_request?(build_request("/jobs"))).to be(false)
      expect(Rack::Attack.auth_request?(build_request("/auth/dfe", method: "POST"))).to be(false)
    end
  end

  describe "fail2ban auth bans" do
    def flood_auth_endpoint(times)
      freeze_time do
        times.times { get "/auth/dfe" }
      end
    end

    it "bans an IP from auth endpoints after too many auth requests, and logs it" do
      allow(Rails.logger).to receive(:warn)

      freeze_time do
        (Rack::Attack::FAIL2BAN_MAXRETRY + 1).times { get "/auth/dfe" }
      end

      expect(response).to have_http_status(:forbidden)
      expect(Rails.logger).to have_received(:warn)
        .with(a_string_matching(/\[rack-attack\] Blocked request/),
              hash_including(matched: "fail2ban auth brute-forcers", ip: "127.0.0.1", path: "/auth/dfe"))
    end

    it "does not ban non-auth traffic (the ban is auth-scoped)" do
      freeze_time do
        (Rack::Attack::FAIL2BAN_MAXRETRY + 1).times { get "/auth/dfe" }
        get "/check"
      end

      expect(response).not_to have_http_status(:forbidden)
    end

    it "does not ban below the strike threshold" do
      freeze_time do
        (Rack::Attack::FAIL2BAN_MAXRETRY / 2).times { get "/auth/dfe" }
        get "/auth/dfe"
      end

      expect(response).not_to have_http_status(:forbidden)
    end

    it "lifts the ban once the ban time has elapsed" do
      flood_auth_endpoint(Rack::Attack::FAIL2BAN_MAXRETRY + 1)
      expect(response).to have_http_status(:forbidden)

      travel(Rack::Attack::FAIL2BAN_BANTIME + 1.minute) do
        get "/auth/dfe"
      end

      expect(response).not_to have_http_status(:forbidden)
    end
  end
end
