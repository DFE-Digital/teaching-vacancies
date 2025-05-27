class WithinUnitedKingdomValidator < ActiveModel::EachValidator
  UK_NAMES = ["united kingdom", "uk", "gb", "great britain", "britain"].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    # Why not use: 'Geocoder.search(value).map(&:country).include?("United Kingdom")'?
    # This would always trigger a new API call to Geocoder, which is not ideal.
    #
    # We are already caching all the search location coordinates to avoid unnecessary API calls and costs.
    # This is done through the Geocoding class, a wrapper around the Geocoder gem that handles the API calls and caching.
    # By reusing the Geocoding class interface, we can avoid triggering API calls when possible and reduce costs.
    coordinates = Geocoding.new(value.strip).coordinates
    return if uk_coordinates?(coordinates, value)

    record.errors.add(attribute, I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
  end

  private

  def uk_coordinates?(coordinates, location_term)
    return false if coordinates.blank? || coordinates == Geocoding::COORDINATES_NO_MATCH

    if coordinates == Geocoding::COORDINATES_UK_CENTROID
      # Google Geocode API returns the UK centroid coordinates when the search options restrict the results to within the UK
      # and the location is outside the UK.
      # Checks if the location term is one of the UK names that should return the centroid coordinates
      location_term.strip.downcase.delete(".").in?(UK_NAMES)
    else
      true # Coordinates are valid and not the UK centroid, so it's in the UK.
    end
  end
end
