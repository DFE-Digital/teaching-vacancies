class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    @buffer_suggestions = get_buffers_suggestions
  end

  def get_buffers_suggestions
    location_names = LocationPolygon.component_location_names(location) ||
                     [LocationPolygon.mapped_name(location)]

    buffer_vacancy_count = Search::RadiusSuggestionsBuilder::RADIUS_OPTIONS.map do |distance|
      locations = LocationPolygon.buffered(distance).where(name: location_names.map(&:downcase))
      polygon_boundaries = locations.compact.flat_map(&:to_algolia_polygons)

      [distance.to_s, Search::Strategies::Algolia.new(search_params.merge(polygons: polygon_boundaries)).total_count]
    end

    buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
