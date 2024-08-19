module Jobseekers::GovukOneLogin
  BASE_URL = Rails.application.config.govuk_one_login_base_url

  CALLBACKS = {
    login: "https://#{ENV.fetch('DOMAIN')}/jobseekers/auth/openid_connect/callback",
    logout: "https://#{ENV.fetch('DOMAIN')}/jobseekers/sign_out",
  }.freeze

  ENDPOINTS = {
    login: "#{BASE_URL}/authorize",
    logout: "#{BASE_URL}/logout",
    token: "#{BASE_URL}/token",
    user_info: "#{BASE_URL}/userinfo",
    jwks: "#{BASE_URL}/.well-known/jwks.json",
  }.freeze
end
