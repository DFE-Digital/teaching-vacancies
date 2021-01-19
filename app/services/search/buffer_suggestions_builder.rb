class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    @buffer_suggestions = buffers_suggestions
  end

  def buffers_suggestions
    if DOWNCASE_COMPOSITE_LOCATIONS.key?(location.downcase)
      polygons = DOWNCASE_COMPOSITE_LOCATIONS[location.downcase].map do |component_region_name|
        LocationPolygon.find_by(name: component_region_name.downcase)
      end

      buffer_vacancy_count = ImportPolygons::BUFFER_DISTANCES_IN_MILES.map do |distance|
        buffers = polygons.map { |polygon| polygon.buffers[distance.to_s] }
        [distance.to_s, Search::AlgoliaSearchRequest.new(search_params.merge(polygons: buffers)).stats.last]
      end
    else
      buffer_vacancy_count = LocationPolygon.with_name(location).buffers.map do |buffer_distance, buffer_polygon|
        [buffer_distance, Search::AlgoliaSearchRequest.new(search_params.merge(polygons: [buffer_polygon])).stats.last]
      end
    end
    buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
