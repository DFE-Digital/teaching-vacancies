class Api::LocationSuggestionController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]
  before_action :check_valid_params, only: %i[show]

  # Caching saves Ordnance Survey Names API calls, which are rate limited per minute (see LocationSuggestion).
  caches_action :show

  def show
    suggestions, matched_terms = LocationSuggestion.new(location).suggest_locations

    render json: {
      query: location,
      suggestions: suggestions,
      matched_terms: matched_terms,
    }
  end

  private

  def location
    params[:location]
  end

  def check_valid_params
    return render(json: { error: "Missing location input" }, status: :bad_request) if location.nil?

    render(json: { error: "Insufficient location input" }, status: :bad_request) if location.length < 3
  end
end
