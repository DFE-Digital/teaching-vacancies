class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    @buffer_suggestions = buffers_suggestions
  end

  def buffers_suggestions
    locations = if DOWNCASE_COMPOSITE_LOCATIONS.key?(location.downcase)
                  DOWNCASE_COMPOSITE_LOCATIONS[location.downcase].map do |component_region_name|
                    LocationPolygon.find_by(name: component_region_name.downcase)
                  end
                else
                  [LocationPolygon.with_name(location)]
                end

    buffer_vacancy_count = ImportPolygons::BUFFER_DISTANCES_IN_MILES.map do |distance|
      buffered_polygons = []
      locations.each do |location|
        location.buffers[distance.to_s].each { |buffer| buffered_polygons.push(buffer) }
      end
      [distance.to_s, Search::AlgoliaSearchRequest.new(search_params.merge(polygons: buffered_polygons)).stats.last]
    end

    buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
