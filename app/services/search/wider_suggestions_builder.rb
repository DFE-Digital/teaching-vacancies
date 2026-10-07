class Search::WiderSuggestionsBuilder
  RADIUS_OPTIONS = [0, 1, 5, 10, 15, 20, 25, 50, 100, 200].freeze

  class << self
    def call(initial_search)
      return if initial_search.location.blank?
      return if initial_search.total_count >= 1

      suggestions initial_search
    end

    def suggestions(initial_search)
      initial_radius = initial_search.radius.to_i
      RADIUS_OPTIONS.select { |r| r > initial_radius }
                                     .map { |radius| [radius.to_s, wider_results_count(initial_search, radius)] }
                                     .uniq(&:second)
                                     .reject { |options| options.second.zero? }
    end

    private

    def wider_results_count(initial_search, radius)
      initial_search.scope_without_location.search_by_location(initial_search.location, radius, polygon: initial_search.polygon).count
    end
  end
end
