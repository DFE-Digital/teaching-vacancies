class Api::LocationSuggestionController < Api::ApplicationController
  before_action :verify_json_request, only: %i[show]
  before_action :check_valid_params, only: %i[show]

  def show
    begin
      suggestions, matched_terms = LocationSuggestion.new(location).suggest_locations
    rescue HTTParty::ResponseError, LocationSuggestion::GooglePlacesAutocompleteError => e
      return render(json: { error: e }, status: :bad_request)
    end
    
    filtered_suggestions = exclude_welsh_locations(suggestions)

    render json: {
      query: location,
      suggestions: filtered_suggestions,
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

  def exclude_welsh_locations(suggestions)
    places_to_exclude = [
      "Wales", "Cardiff", "Saint Asaph", "Swansea", "Denbigh", "Newport", "St Davids", "Caerlon", "Lampeter", "Bala", "Pembroke", "Rhayader",
      "Bangor", "Welshpool", "Llanfyllin", "Rhondaa", "Gelligaer", "Machynlleth", "Kidwelly", "Aberaeron", "Cardigan", "Narberth", "Harlech", "Talgarth",
      "Gwersyllt", "Aberaman", "Bagillt", "Flint", "Carmarthen", "Buckley", "Neath", "Aberystwyth", "Llantwit Major", "Milford Haven", "Caerphilly", "Tonyrefail",
      "Maesteg", "Haverfordwest", "Aberdare", "Connah's Quay", "Barry", "Rhyl", "Risca", "Prestatyn", "Brackla", "Conwy", "Flintshire"
    ]

    postcode_pattern_to_exclude = /(LL|SY|LD|SA|CF|NP)\d/

    suggestions.reject do |str|
      str.match?(postcode_pattern_to_exclude) || places_to_exclude.include?(str)
    end
  end
end
