Recaptcha.configure do |config|
  config.site_key = ENV.fetch("RECAPTCHA_V2_SITE_KEY", "Placeholder")
  config.secret_key = ENV.fetch("RECAPTCHA_V2_SECRET_KEY", "Placeholder")
end
