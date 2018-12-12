module OmniAuth
  module Strategies
    class OpenIDConnect
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/LineLength
      # rubocop:disable Style/GuardClause
      # Please refer to this commit to read why this has been copied from: https://github.com/m0n9oose/omniauth_openid_connect/blob/master/lib/omniauth/strategies/openid_connect.rb
      def callback_phase
        error = request.params['error_reason'] || request.params['error']
        if error
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        elsif request.params['state'].to_s.empty? || request.params['state'] != stored_state
          return redirect('/401')
        elsif !request.params['code']
          return fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params['error']))
        else
          options.issuer = issuer if options.issuer.blank?
          discover! if options.discovery
          client.redirect_uri = redirect_uri
          client.authorization_code = authorization_code
          access_token
          super
        end
      rescue CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/LineLength
      # rubocop:enable Style/GuardClause
    end
  end
end

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

# Docker initialises the application (during `docker build`) in a context where
# there are no environment variables. This guard clause is cleaner than multiple
# `ENV.fetch` that sets up defaults.
if ENV['DFE_SIGN_IN_ISSUER'].present?
  dfe_sign_in_issuer_uri = URI.parse(ENV['DFE_SIGN_IN_ISSUER'])
  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    client_signing_alg: :RS256,
    scope: %i[openid profile email organisation],
    client_options: {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
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
