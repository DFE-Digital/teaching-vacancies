class Api::ApplicationController < ApplicationController
  skip_after_action :trigger_page_visited_event

  private

  def request_event
    ApiRequestEvent.new(request, response, session)
  end

  def set_headers
    response.set_header("X-Robots-Tag", "noarchive")
    response.charset = "utf-8"
  end

  def verify_json_request
    not_found unless request.format.json?
  end
end
