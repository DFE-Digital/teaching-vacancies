class Api::ApplicationController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
    response.charset = "utf-8"
  end

  def verify_json_request
    not_found unless request.format.json?
  end
end
