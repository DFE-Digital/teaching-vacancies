module Jobseekers::GovukOneLogin
  BASE_URL = Rails.application.config.govuk_one_login_base_url
  CALLBACKS_BASE_URL = "#{ENV.fetch('DOMAIN').include?('localhost') ? 'http' : 'https'}://#{ENV.fetch('DOMAIN')}".freeze

  CALLBACKS = {
    login: "#{CALLBACKS_BASE_URL}/jobseekers/auth/openid_connect/callback",
    logout: "#{CALLBACKS_BASE_URL}/jobseekers/sign_out",
  }.freeze

  ENDPOINTS = {
    login: "#{BASE_URL}/authorize",
    logout: "#{BASE_URL}/logout",
    token: "#{BASE_URL}/token",
    user_info: "#{BASE_URL}/userinfo",
    jwks: "#{BASE_URL}/.well-known/jwks.json",
  }.freeze

  User = Struct.new(:id, :email, :id_token, keyword_init: true)
end
