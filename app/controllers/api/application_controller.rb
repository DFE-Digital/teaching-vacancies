class Api::ApplicationController < ApplicationController
  rescue_from StandardError, with: :handle_internal_server_error

  private

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
    response.charset = "utf-8"
  end

  def verify_json_request
    not_found unless request.format.json?
  end

  def handle_internal_server_error(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render json: { error: "Internal server error", message: exception.message }, status: :internal_server_error
  end
end
