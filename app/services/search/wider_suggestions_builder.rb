class Search::WiderSuggestionsBuilder
  include DistanceHelper
  include VacanciesOptionsHelper

  attr_reader :search_criteria

  def initialize(search_criteria)
    @search_criteria = search_criteria
  end

  def initial_radius
    return Integer(search_criteria[:radius]) if search_criteria[:radius]

    0
  end

  def suggestions
    @suggestions ||= RADIUS_OPTIONS.select { |r| r > initial_radius }
                                   .map { |radius| [radius.to_s, wider_results_count(radius)] }
                                   .uniq(&:second)
                                   .reject { |options| options.second.zero? }
  end

  private

  def wider_results_count(radius)
    Search::VacancySearch.new(search_criteria.merge(radius: radius)).total_count
  end
end
