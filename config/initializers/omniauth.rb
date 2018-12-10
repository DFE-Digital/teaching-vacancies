# Docker build will fail without this guard
DFE_SIGNIN_ENABLED = ENV['DFE_SIGN_IN_ISSUER'].present?

if DFE_SIGNIN_ENABLED
  dfe_sign_in_url = URI.parse(ENV['DFE_SIGN_IN_ISSUER'])
  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    client_signing_alg: :RS256,
    scope: %i[openid profile email organisation],
    client_options: {
      port: dfe_sign_in_url.port,
      scheme: dfe_sign_in_url.scheme,
      host: dfe_sign_in_url.host,
      identifier: ENV['DFE_SIGN_IN_IDENTIFIER'],
      secret: ENV['DFE_SIGN_IN_SECRET'],
      redirect_uri: ENV['DFE_SIGN_IN_REDIRECT_URL'],
      authorization_endpoint: '/auth',
      jwks_uri: '/certs',
      userinfo_endpoint: '/me'
    }
  }

  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options

  class DfeSignIn
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path == '/auth/dfe/callback' && request.params.empty? && !OmniAuth.config.test_mode
        response = Rack::Response.new
        response.redirect('/dfe/sessions/new')
        response.finish
      else
        @app.call(env)
      end
    end
  end

  Rails.application.config.middleware.insert_before OmniAuth::Strategies::OpenIDConnect, DfeSignIn
end
