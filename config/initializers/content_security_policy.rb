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
                       "https://api.rollbar.com",
                       "https://www.google-analytics.com",
                       *development_env_additional_connect_src # Allow using webpack-dev-server in development

    policy.font_src    :self,
                       :data

    policy.frame_src   :self,
                       "https://www.recaptcha.net",
                       "https://www.googletagmanager.com"

    policy.img_src     :self,
                       :https,
                       :data

    policy.object_src  :none

    policy.script_src  :self,
                       :unsafe_inline, # Backwards compatibility; ignored by modern browsers as we set a nonce for scripts
                       "https://cdn.rollbar.com",
                       "https://www.google-analytics.com",
                       "https://www.googletagmanager.com",
                       "https://www.recaptcha.net"

    policy.style_src   :self

    # Specify URI for violation reports
    policy.report_uri "/errors/csp_violation"

    # Enable automatic nonce generation for <script> tags
    config.content_security_policy_nonce_generator = ->(_) { SecureRandom.base64(16) }

    # Set the nonce only to `script-src` directive (because of Google Maps issue detailed above)
    config.content_security_policy_nonce_directives = %w[script-src]

    # Make the CSP report only (default is `false`, commented out to make it enforce)
    # config.content_security_policy_report_only = true
  end
end
