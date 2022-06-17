# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self

    development_env_additional_connect_src = %w[http://localhost:3035 ws://localhost:3035] if Rails.env.development?
    policy.connect_src :self,
                       "https://api.postcodes.io",
                       "https://*.sentry.io",
                       "https://*.google-analytics.com",
                       "https://*.analytics.google.com",
                       *development_env_additional_connect_src # Allow using webpack-dev-server in development

    policy.font_src    :self,
                       :data

    policy.frame_src   :self,
                       "https://2673654.fls.doubleclick.net", # Floodlight
                       "https://www.recaptcha.net",
                       "https://www.googletagmanager.com"

    policy.img_src     :self,
                       :https,
                       :data,
                       "https://2673654.fls.doubleclick.net" # Floodlight

    policy.object_src  :none

    policy.script_src  :self,
                       :unsafe_inline, # Backwards compatibility; ignored by modern browsers as we set a nonce for scripts
                       "https://cdn.rollbar.com",
                       "https://www.google-analytics.com",
                       "https://www.googletagmanager.com",
                       "https://www.recaptcha.net"

    policy.style_src   :self
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }

  # Set nonce only for scripts
  # TODO: We tried removing this and it caused a flood of CSP violations from Mobile Safari.
  #       Investigate again later.
  config.content_security_policy_nonce_directives = %w[script-src]
end
