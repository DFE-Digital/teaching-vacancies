module OmniAuth
  module Strategies
    class OpenIDConnect
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Layout/LineLength
      # rubocop:disable Style/GuardClause
      # Please refer to this commit to read why this has been copied from: https://github.com/m0n9oose/omniauth_openid_connect/blob/master/lib/omniauth/strategies/openid_connect.rb
      def callback_phase
        Rollbar.log(:info, 'A sign-in callback was started',
                    stored_state: session['omniauth.state'],
                    accept_header: request.has_header?('Accept') ? request.get_header('Accept') : request.get_header('HTTP_ACCEPT'),
                    time: Time.zone.now.strftime('%Y-%m-%d %H:%M:%S:%L'))
        error = request.params['error_reason'] || request.params['error']
        if error
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        elsif request.params.blank? && request.path == '/auth/dfe/callback'
          response = Rack::Response.new
          response.redirect('/dfe/sessions/new')
          response.finish
        elsif request.params['state'].to_s.empty? || request.params['state'] != stored_state
          Rollbar.log(:error,
                      'A sign-in callback was unauthorised',
                      session_id: session.id,
                      received_state: request.params['state'],)
          redirect('/401')
        elsif !request.params['code']
          fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params['error']))
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
      # rubocop:enable Layout/LineLength
      # rubocop:enable Style/GuardClause
    end
  end
end

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

Rails.application.config.middleware.use OmniAuth::Builder do
  dfe_sign_in_issuer_uri    = URI(ENV.fetch('DFE_SIGN_IN_ISSUER', 'example'))
  dfe_sign_in_identifier    = ENV.fetch('DFE_SIGN_IN_IDENTIFIER', 'example')
  dfe_sign_in_secret        = ENV.fetch('DFE_SIGN_IN_SECRET', 'example')
  dfe_sign_in_redirect_uri  = ENV.fetch('DFE_SIGN_IN_REDIRECT_URL', 'example')

  dfe_sign_in_issuer_url = "#{dfe_sign_in_issuer_uri}:#{dfe_sign_in_issuer_uri.port}" if dfe_sign_in_issuer_uri.port

  provider :dfe,
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
             authorization_endpoint: '/auth',
             jwks_uri: '/certs',
             userinfo_endpoint: '/me'
           }
end
