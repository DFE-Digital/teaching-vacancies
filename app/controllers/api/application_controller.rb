class Api::ApplicationController < ApplicationController
  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
    response.charset = 'utf-8'
  end

  def verify_json_request
    not_found unless request.format.json?
  end

  def verify_same_domain
    return if Rails.env.development? # HTTP origin header is nil in development
    not_found unless request.headers['origin'] == Rails.application.config.allowed_cors_origin
  end
end
