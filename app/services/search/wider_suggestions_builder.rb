class Search::WiderSuggestionsBuilder
  include DistanceHelper
  include VacanciesOptionsHelper

  attr_reader :search_criteria, :initial_radius, :initial_search

  def self.call(search_instance)
    builder = new(search_instance)
    return if builder.search_criteria[:location].blank?
    return if builder.initial_search.total_count >= 1

    builder.suggestions
  end

  def initialize(initial_search)
    @initial_search = initial_search
    @search_criteria = initial_search.search_criteria
    @initial_radius = initial_search.search_criteria[:radius].to_i
  end

  def suggestions
    @suggestions ||= RADIUS_OPTIONS.select { |r| r > initial_radius }
                                   .map { |radius| [radius.to_s, wider_results_count(radius)] }
                                   .uniq(&:second)
                                   .reject { |options| options.second.zero? }
  end

  private

  def wider_results_count(radius)
    initial_search.class.new(
      search_criteria.merge(radius: radius),
      scope: initial_search.original_scope,
    ).total_count
  end
end
