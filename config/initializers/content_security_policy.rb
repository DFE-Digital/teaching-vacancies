# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  policy.font_src    :self,
                     :data,
                     "https://cdnjs.cloudflare.com",
                     "https://fonts.gstatic.com"

  policy.frame_src   :self,
                     "https://www.google.com", # for reCAPTCHA
                     "https://www.googletagmanager.com"

  policy.img_src     :self,
                     :https,
                     :data,
                     "http://maps.google.com"

  policy.object_src  :none

  policy.script_src  :self,
                     :unsafe_inline, # Backwards compatibility; ignored by modern browsers as we set a nonce for scripts
                     "https://cdn.rollbar.com",
                     "https://cdnjs.cloudflare.com",
                     "https://maps.googleapis.com",
                     "https://www.google-analytics.com",
                     "https://www.googletagmanager.com",
                     "https://www.recaptcha.net"

  # Google Maps embed will not work without 'unsafe-inline' styles
  #   see: https://issuetracker.google.com/issues/132600807
  policy.style_src   :self,
                     :unsafe_inline,
                     "https://cdnjs.cloudflare.com",
                     "https://fonts.googleapis.com"

  policy.connect_src :self,
                     "https://api.postcodes.io",
                     "https://api.rollbar.com",
                     "https://www.google-analytics.com"

  # Allow using webpack-dev-server in development
  policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

  # Specify URI for violation reports
  policy.report_uri "/errors/csp_violation"
end

# Enable automatic nonce generation for <script> tags
Rails.application.config.content_security_policy_nonce_generator = ->(_) { SecureRandom.base64(16) }

# Set the nonce only to `script-src` directive (because of Google Maps issue detailed above)
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
Rails.application.config.content_security_policy_report_only = true
