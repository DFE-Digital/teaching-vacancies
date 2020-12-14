class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    get_buffers_suggestions
  end

  def get_buffers_suggestions
    buffer_vacancy_count = LocationPolygon.with_name(location).buffers.map do |buffer|
      [buffer.first, Search::AlgoliaSearchRequest.new(search_params.merge(polygon: [buffer.last])).stats.last]
    end

    @buffer_suggestions = buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
