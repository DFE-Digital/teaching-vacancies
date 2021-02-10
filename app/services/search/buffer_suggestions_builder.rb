class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    @buffer_suggestions = get_buffers_suggestions
  end

  def get_buffers_suggestions
    locations = if LocationPolygon.composite?(location)
                  LocationPolygon.component_location_names(location).map do |component_region_name|
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
      [distance.to_s, Search::AlgoliaSearchRequest.new(search_params.merge(polygons: buffered_polygons)).total_count]
    end

    buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
