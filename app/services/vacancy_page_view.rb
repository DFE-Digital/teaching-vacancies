class VacancyPageView < Counter
  @redis_counter_name = :page_view_counter
  @persisted_column = :total_pageviews

  def initialize(vacancy)
    @model = vacancy
  end
end
