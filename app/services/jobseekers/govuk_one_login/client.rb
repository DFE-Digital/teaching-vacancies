#
# - exchange an authorisation code for tokens (access and id)
# - exchange an access token for user info
# - decode an id token to get the user's gov one id
#
# see https://docs.sign-in.service.gov.uk/
class Jobseekers::GovukOneLogin::Client
  include Jobseekers::GovukOneLogin

  JWT_SIGNING_ALGORITHM = "RS256".freeze

  attr_reader :code

  def initialize(code)
    @code = code
  end

  # POST /token
  def tokens
    uri, http = build_http(ENDPOINTS[:token])
    request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/x-www-form-urlencoded" })
    request.set_form_data({ grant_type: "authorization_code",
                            code: code,
                            redirect_uri: CALLBACKS[:login],
                            client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
                            client_assertion: jwt_assertion })
    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "GovukOneLogin.tokens: #{e.message}"
    {}
  end

  # GET /userinfo
  def user_info(access_token)
    uri, http = build_http(ENDPOINTS[:user_info])
    request = Net::HTTP::Get.new(uri.path, { "Authorization" => "Bearer #{access_token}" })
    response = http.request(request)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "GovukOneLogin.user_info: #{e.message}"
    {}
  end

  def decode_id_token(token)
    kid = JWT.decode(token, nil, false).last["kid"]
    key_params = jwks["keys"].find { |key| key["kid"] == kid }
    jwk = JWT::JWK.new(key_params)

    JWT.decode(token, jwk.public_key, true, { verify_iat: true, algorithm: JWT_SIGNING_ALGORITHM })
  end

  private

  def build_http(address)
    uri = URI.parse(address)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    [uri, http]
  end

  # GET /.well-known/jwks.json
  def jwks
    Rails.cache.fetch("jwks", expires_in: 24.hours) do
      uri, http = build_http(ENDPOINTS[:jwks])
      response = http.request(Net::HTTP::Get.new(uri.path))
      JSON.parse(response.body)
    end
  end

  def jwt_assertion
    rsa_private = OpenSSL::PKey::RSA.new(Rails.application.config.govuk_one_login_private_key)
    JWT.encode(jwt_payload, rsa_private, JWT_SIGNING_ALGORITHM)
  end

  def jwt_payload
    {
      aud: ENDPOINTS[:token],
      iss: Rails.application.config.govuk_one_login_client_id,
      sub: Rails.application.config.govuk_one_login_client_id,
      exp: Time.zone.now.to_i + (5 * 60),
      jti: SecureRandom.uuid,
      iat: Time.zone.now.to_i,
    }
  end
end
