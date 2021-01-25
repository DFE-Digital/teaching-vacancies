class Search::BufferSuggestionsBuilder
  attr_reader :location, :buffer_suggestions, :search_params

  def initialize(location, search_params)
    @location = location
    @search_params = search_params
    get_buffers_suggestions
  end

  def get_buffers_suggestions
    buffer_vacancy_count = LocationPolygon.with_name(location).buffers.map do |buffer|
      # In this step (2) of the LocationPolygon refactor, the format of buffers will be different
      # before and after running the import task. Before it's a 1D array; after, it's 2D. So I am temporarily
      # rewriting this method to cope with both formats. This will be reverted in step 3.
      polygon = if buffer.last.first.is_a?(Float)
                  buffer.last
                else
                  buffer.last.first
                end

      [buffer.first, Search::AlgoliaSearchRequest.new(search_params.merge(polygon: [polygon])).stats.last]
    end

    @buffer_suggestions = buffer_vacancy_count&.uniq(&:last)&.reject { |array| array.last.zero? }
  end
end
