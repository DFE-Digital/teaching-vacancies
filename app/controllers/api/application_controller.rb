class Api::ApplicationController < ApplicationController
  def set_headers
    response.set_header('X-Robots-Tag', 'noarchive')
  end

  def verify_json_request
    not_found unless request.format.json?
  end

  def verify_json_or_csv_request
    not_found unless request.format.json? || request.format.csv?
  end
end
