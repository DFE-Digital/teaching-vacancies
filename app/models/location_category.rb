class LocationCategory
  def self.include?(location)
    ALL_LOCATION_CATEGORIES.include?(location.downcase)
  end
end
