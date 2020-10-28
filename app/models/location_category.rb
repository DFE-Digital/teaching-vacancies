class LocationCategory
  def self.include?(location)
    ALL_LOCATION_CATEGORIES.include?((MAPPED_LOCATIONS[location.downcase].presence || location).downcase)
  end
end
