module Jobseekers::GovukOneLogin::Helper
  include Jobseekers::GovukOneLogin

  def generate_login_params
    {
      redirect_uri: CALLBACKS[:login],
      client_id: Rails.application.config.govuk_one_login_client_id,
      response_type: "code",
      scope: "email openid",
      nonce: SecureRandom.alphanumeric(25),
      state: SecureRandom.uuid,
    }
  end

  def generate_logout_params(session_id_token)
    {
      post_logout_redirect_uri: CALLBACKS[:logout],
      id_token_hint: session_id_token,
      state: SecureRandom.uuid,
    }
  end

  def govuk_one_login_uri(endpoint, params)
    URI.parse(ENDPOINTS[endpoint]).tap do |uri|
      uri.query = URI.encode_www_form(params)
    end
  end
end
