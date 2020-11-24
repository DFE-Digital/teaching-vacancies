class Search::SuggestionsBuilder
  RADIUS_OPTIONS = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 100, 200].freeze

  attr_reader :radius, :radius_suggestions, :search_params

  def initialize(search_params, radius)
    @radius = radius.to_i
    @search_params = search_params
    get_radius_suggestions
  end

  def get_radius_suggestions
    radius_idx = RADIUS_OPTIONS.find_index(radius)
    wider_radii = (1..5).map { |idx| RADIUS_OPTIONS[radius_idx + idx] } unless radius_idx.nil?
    wider_radii_counts = wider_radii&.map { |wider_radius|
      unless wider_radius.nil?
        [
          wider_radius,
          Search::AlgoliaSearch.new(
            search_params.merge(radius: Search::LocationBuilder.convert_radius_in_miles_to_metres(wider_radius)),
          ).stats.last,
        ]
      end
    }&.reject(&:nil?)

    @radius_suggestions = wider_radii_counts&.uniq(&:last)&.reject { |arr| arr.last.zero? }
  end
end
