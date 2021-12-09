class Search::WiderSuggestionsBuilder
  include DistanceHelper
  include VacanciesOptionsHelper

  attr_reader :search_params

  def initialize(search_params)
    @search_params = search_params
  end

  def suggestions
    RADIUS_OPTIONS
      .select { |r| r > search_params[:radius] }
      .map { |radius| [radius.to_s, wider_results(radius)] }
      .uniq(&:second)
      .reject { |options| options.second.zero? }
  end

  private

  def wider_results(radius)
    Search::Strategies::PgSearch.new(**search_params.merge(radius: radius)).total_count
  end
end
