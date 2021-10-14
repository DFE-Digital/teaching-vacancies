class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    @buffer_suggestions = get_buffers_suggestions
  end

  def get_buffers_suggestions
    buffer_vacancy_count = Search::RadiusSuggestionsBuilder::RADIUS_OPTIONS.map do |distance|
      polygons = LocationPolygon.buffered(distance).with_name(location).to_algolia_polygons

      [distance.to_s, Search::Strategies::Algolia.new(search_params.merge(polygons: polygons)).total_count]
    end

    buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
