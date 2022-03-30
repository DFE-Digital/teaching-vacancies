class DSIClient
  def initialize(user_id:, organisation_id:)
    @organisation_id = organisation_id
    @user_id = user_id
  end

  def role_ids
    @role_ids ||= roles.map { |r| r[:id] }
  end

  def roles
    user_info[:roles]
  end

  private

  def user_info
    @user_info ||= get("/services/#{service_id}/organisations/#{@organisation_id}/users/#{@user_id}")
  end

  def get(path)
    uri = uri_for_path(path)
    request = request_for_uri(uri)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    DSIClient::Response.new(response).tap do |r|
      raise DSIClient::RequestInvalid, response.code if r.invalid?
      raise DSIClient::RequestFailed, response.code if r.failure?
    end
  end

  def uri_for_path(path)
    URI(ENV.fetch("DFE_SIGN_IN_URL")).tap do |uri|
      uri.path = path
    end
  end

  def request_for_uri(uri)
    Net::HTTP::Get.new(uri).tap do |request|
      request["Authorization"] = "Bearer #{jwt_token}"
      request["Content-Type"] = "application/json"
    end
  end

  def jwt_token
    payload = {
      iss: "schooljobs",
      exp: (Time.current.getlocal + 60).to_i,
      aud: "signin.education.gov.uk",
    }

    JWT.encode(payload, password, "HS256")
  end

  def service_id
    ENV.fetch("DFE_SIGN_IN_SERVICE_ID")
  end

  def password
    ENV.fetch("DFE_SIGN_IN_PASSWORD")
  end

  class Response
    def initialize(net_http_response)
      @net_http_response = net_http_response
    end

    delegate :body, :code, to: :@net_http_response
    delegate :[], to: :data

    def success?
      code == "200"
    end

    def invalid?
      code.starts_with?("4")
    end

    def failure?
      code.starts_with?("5")
    end

    def data
      JSON.parse(body, symbolize_names: true)
    end
  end

  class RequestInvalid < StandardError; end
  class RequestFailed < StandardError; end
end
