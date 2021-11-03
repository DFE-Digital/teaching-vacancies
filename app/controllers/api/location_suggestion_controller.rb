class Api::LocationSuggestionController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]
  before_action :check_valid_params, only: %i[show]
  skip_after_action :trigger_page_visited_event

  def show
    begin
      suggestions, matched_terms = LocationSuggestion.new(location).suggest_locations
    rescue HTTParty::ResponseError, LocationSuggestion::GooglePlacesAutocompleteError => e
      return render(json: { error: e }, status: :bad_request)
    end

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
    return render(json: { error: "Insufficient location input" }, status: :bad_request) if location.length < 3
  end
end
