# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self

    policy.connect_src :self,
                       "https://api.postcodes.io",
                       "https://*.sentry.io",
                       "https://*.google-analytics.com",
                       "https://*.analytics.google.com",
                       "https://*.doubleclick.net", # Floodlight
                       "https://www.google.com", # Floodlight
                       "https://www.googleadservices.com", # Floodlight
                       "https://www.googletagmanager.com",
                       "https://pagead2.googlesyndication.com", # Floodlight
                       "https://*.visualwebsiteoptimizer.com",
                       "https://*.clarity.ms",
                       "https://www.facebook.com",
                       "https://connect.facebook.net",
                       "https://www.redditstatic.com",
                       "https://pixel-config.reddit.com",
                       "https://conversions-config.reddit.com",
                       "https://snap.licdn.com",
                       "https://px.ads.linkedin.com",
                       "https://www.recaptcha.net",
                       "https://*.s3.eu-west-2.amazonaws.com"

    policy.font_src    :self,
                       :data,
                       "https://fonts.gstatic.com"

    policy.frame_src   :self,
                       "https://*.doubleclick.net", # Floodlight
                       "https://www.recaptcha.net",
                       "https://www.googletagmanager.com", # Floodlight
                       "https://www.youtube.com"

    policy.img_src     :self,
                       :https,
                       :data,
                       "https://*.doubleclick.net", # Floodlight
                       "https://ade.googlesyndication.com", # Floodlight
                       "https://adservice.google.com", # Floodlight
                       "https://www.googletagmanager.com", # Floodlight
                       "https://googletagmanager.com", # Tag Manager preview mode
                       "https://ssl.gstatic.com", # Tag Manager preview mode
                       "https://www.gstatic.com" # Tag Manager preview mode

    policy.object_src  :none

    policy.script_src  :self,
                       :unsafe_inline, # Backwards compatibility; ignored by modern browsers as we set a nonce for scripts
                       "https://cdn.rollbar.com",
                       "https://www.google-analytics.com",
                       "https://www.googletagmanager.com",
                       "https://googletagmanager.com", # Tag Manager preview mode
                       "https://tagmanager.google.com", # Tag Manager preview mode
                       "https://www.recaptcha.net",
                       "https://*.visualwebsiteoptimizer.com",
                       "https://connect.facebook.net",
                       "https://snap.licdn.com",
                       "https://www.redditstatic.com",
                       "https://www.clarity.ms",
                       "https://scripts.clarity.ms",
                       "https://www.gstatic.com"

    policy.style_src   :self,
                       :unsafe_inline,
                       "https://fonts.gstatic.com/*",
                       "https://www.gstatic.com",
                       "https://googletagmanager.com", # Tag Manager preview mode
                       "https://tagmanager.google.com", # Tag Manager preview mode
                       "https://fonts.googleapis.com" # Tag Manager preview mode

    policy.worker_src  :self,
                       :blob,
                       "https://*.visualwebsiteoptimizer.com"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }

  # Set nonce only for scripts
  # TODO: We tried removing this and it caused a flood of CSP violations from Mobile Safari.
  #       Investigate again later.
  config.content_security_policy_nonce_directives = %w[script-src]
end
