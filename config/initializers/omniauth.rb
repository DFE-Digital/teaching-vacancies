class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end
class OmniAuth::Strategies::GovukOneLogin < OmniAuth::Strategies::OpenIDConnect; end

Rails.application.config.middleware.use OmniAuth::Builder do
  dfe_sign_in_issuer_uri    = URI(ENV.fetch("DFE_SIGN_IN_ISSUER", "example"))
  dfe_sign_in_identifier    = ENV.fetch("DFE_SIGN_IN_IDENTIFIER", "example")
  dfe_sign_in_secret        = ENV.fetch("DFE_SIGN_IN_SECRET", "example")
  dfe_sign_in_redirect_uri  = ENV.fetch("DFE_SIGN_IN_REDIRECT_URL", "example")

  dfe_sign_in_issuer_url = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.port
  provider(
    :dfe,
    name: :dfe,
    discovery: true,
    response_type: :code,
    issuer: dfe_sign_in_issuer_url,
    client_signing_alg: :RS256,
    scope: %i[openid profile email organisation],
    client_options: {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
      identifier: dfe_sign_in_identifier,
      secret: dfe_sign_in_secret,
      redirect_uri: dfe_sign_in_redirect_uri,
      authorization_endpoint: "/auth",
      jwks_uri: "/certs",
      userinfo_endpoint: "/me",
    },
  )

  provider(
    :govuk_one_login,
    name: :govuk_one_login,
    scope: %i[openid email],
    response_type: :code,
    client_options: {
      port: 443,
      scheme: "https",
      host: Rails.application.config.govuk_one_login_base_url,
      identifier: Rails.application.config.govuk_one_login_client_id,
      redirect_uri: "jobseekers/auth/govuk_one_login/callback",
    },
    authorize_params: {
      prompt: "login",
    },
  )

  on_failure do |env|
    OmniauthCallbacksController
      .action(:failure)
      .call(env.merge("devise.mapping" => Devise.mappings[:publisher]))
  end
end
