class Api::ApplicationController < ApplicationController
  rescue_from StandardError, with: :render_server_error

  private

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
    response.charset = "utf-8"
  end

  def verify_json_request
    not_found unless request.format.json?
  end

  def render_server_error(exception)
    render json: { error: "Internal server error", message: exception.message }, status: :internal_server_error
  end

  def render_not_found
    render json: { error: "The given ID does not match any vacancy for your ATS" }, status: :not_found
  end

  def render_bad_request
    render json: { error: "Request body could not be read properly" }, status: :bad_request
  end
end
